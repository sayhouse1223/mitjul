import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // ChangeNotifier를 위해 import 추가
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/naver_search_api_service.dart';

enum SearchStatus { idle, loading, success, empty, error }

class BookSearchController extends ChangeNotifier {
  BookSearchController({NaverSearchApiService? apiService})
      : _apiService = apiService ?? NaverSearchApiService();

  final NaverSearchApiService _apiService;

  // -- 페이지네이션 및 상태 관련 변수 --
  SearchStatus _status = SearchStatus.idle;
  List<Book> _books = [];
  String? _errorMessage;
  String _lastQuery = '';
  
  int _currentPage = 0; // 현재 페이지 (1페이지부터 시작하므로 0으로 초기화)
  bool _hasMore = false; // 더 불러올 결과가 있는지 여부
  bool _isFetchingMore = false; // 추가 로딩 중인지 여부

  // -- Getters --
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  SearchStatus get status => _status;
  List<Book> get books => _books;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;
  bool get isLoading => _status == SearchStatus.loading;

  // ----------------------------------------------------
  // MARK: - 검색 및 페이지네이션 로직
  // ----------------------------------------------------

  Future<void> search(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      _reset();
      return;
    }

    _status = SearchStatus.loading;
    _errorMessage = null;
    _currentPage = 0; // 새 검색 시작 시 페이지 초기화
    _hasMore = false;
    notifyListeners();

    // 첫 페이지 (start=1) 호출
    await _fetchBooks(trimmed, 1, append: false);
  }

  // 추가 데이터 로딩 함수 (스크롤 끝에 도달했을 때 호출)
  Future<void> fetchMore() async {
    // 이미 로딩 중이거나, 더 이상 결과가 없거나, 검색 성공 상태가 아니면 리턴
    if (!_hasMore || _isFetchingMore || _status != SearchStatus.success) return;

    _isFetchingMore = true;
    notifyListeners();

    // 다음 페이지의 start 값 계산: (현재 페이지 * display 개수) + 1
    // API service에서 display=20으로 설정했음을 가정합니다.
    final nextStart = (_currentPage * 20) + 1; 
    
    await _fetchBooks(_lastQuery, nextStart, append: true);

    _isFetchingMore = false;
    notifyListeners();
  }

  // 실제 API 호출을 수행하는 내부 함수
  Future<void> _fetchBooks(String query, int start, {required bool append}) async {
    try {
      // API 호출 시 start 파라미터 전달
      final results = await _apiService.searchBooks(query, start: start); 
      
      // List<Book> 타입을 명시적으로 지정하여 타입 오류를 방지합니다.
      final currentBooks = append ? _books : <Book>[]; 
      currentBooks.addAll(results);
      
      // 검색 결과를 우선순위에 따라 정렬 (새로 추가된 데이터까지 포함하여 정렬)
      final sortedResults = _sortBooksByPriority(currentBooks, query);
      
      _books = sortedResults;
      
      _currentPage = start ~/ 20 + 1; // 현재 페이지 업데이트
      
      // 다음 페이지가 있는지 판단 (받아온 결과가 20개 미만이면 마지막 페이지)
      _hasMore = results.length == 20; 
      
      if (_books.isEmpty) {
        _status = SearchStatus.empty;
      } else {
        _status = SearchStatus.success;
      }
      
      notifyListeners(); // 상태 변경 시 항상 알림
      
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = '검색 중 오류가 발생했습니다. 다시 시도해주세요.';
      if (!append) _books = []; // 첫 검색 실패 시 목록 초기화
      if (kDebugMode) print('BookSearchController error: $e');
      notifyListeners(); // 에러 발생 시에도 알림
    }
  }

  void clear() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _status = SearchStatus.idle;
    _books = [];
    _errorMessage = null;
    _lastQuery = '';
    _currentPage = 0;
    _hasMore = false;
    _isFetchingMore = false;
  }
  
  // ----------------------------------------------------
  // MARK: - 정렬 로직 및 유틸리티 함수
  // ----------------------------------------------------

  // '없음' 텍스트를 포함하는지 확인하는 유틸리티 함수
  bool _containsNoInfoText(String? text) {
    if (text == null || text.isEmpty) return false;
    final lowerText = text.toLowerCase();
    return lowerText.contains('없음') || 
           lowerText.contains('no info') || 
           lowerText.contains('정보 없음') || 
           lowerText.contains('unknown') ||
           lowerText.contains('n/a') ||
           lowerText.trim().isEmpty;
  }
  
  // [1순위] 통합 누락 상태 점수 함수 (Data Integrity)
  int _getIntegratedMissingScore(Book book) {
    // 1. 심각 누락 체크 (가장 높은 패널티)
    if (_containsNoInfoText(book.title) || 
        (book.authors != null && book.authors!.any((author) => _containsNoInfoText(author))) ||
        _containsNoInfoText(book.publisher)) {
      return 2; // 심각한 누락 -> 가장 후순위 그룹
    }

    // 2. 일반 누락 개수 체크 (중간 패널티)
    int generalMissingCount = 0;
    if (book.authors == null || book.authors!.isEmpty) {
        generalMissingCount++;
    }
    if (book.publisher == null || book.publisher!.isEmpty) {
        generalMissingCount++;
    }
    
    if (generalMissingCount > 0) {
        return 1; // Null/Empty 필드가 하나라도 있음 -> 중간 순위 그룹
    }
    
    // 3. 누락 없음 (최고 순위)
    return 0; // 정보 완벽 -> 최상위 그룹
  }

  // [2순위] 제목 일치도 계산 함수 (Title Match)
  // **[수정] query 파라미터를 받도록 수정**
  int getTitleMatchScore(Book book, String query) {
    final lowerQuery = query.toLowerCase();
    final lowerTitle = book.title.toLowerCase().trim();
      
    if (lowerTitle == lowerQuery) {
      return 3; // 완벽 일치
    }
    if (lowerTitle.contains(lowerQuery)) {
      return 2; // 부분 일치
    }
    return 1; // 불일치 (최소 점수)
  }
  
  // [3순위] 저자/출판사 일치도 계산 함수 (Author/Pub Match)
  // **[수정] query 파라미터를 받도록 수정**
  int getAuthorPublisherMatchScore(Book book, String query) {
    final lowerQuery = query.toLowerCase();
    
    // 저자 일치 확인
    if (book.authors != null && book.authors!.any((author) => author.toLowerCase().contains(lowerQuery))) {
      return 2; 
    }
    
    // 출판사 일치 확인
    if (book.publisher != null && book.publisher!.toLowerCase().contains(lowerQuery)) {
      return 2;
    }
      
    return 1; // 불일치 (최소 점수)
  }
  
  // [6순위] publishedDate 문자열을 DateTime으로 파싱
  DateTime? _parsePublishedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    // 네이버 pubdate 형식: YYYYMMDD 처리
    if (dateString.length == 8) {
      try {
        final year = dateString.substring(0, 4);
        final month = dateString.substring(4, 6);
        final day = dateString.substring(6, 8);
        return DateTime.parse('$year-$month-$day');
      } catch (_) {
        return null;
      }
    }
    
    // 기타 표준 형식 시도
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
  
  // 정렬 함수 (Final Code - 이미지 우선순위에 맞춤)
  List<Book> _sortBooksByPriority(List<Book> books, String query) {
    if (books.isEmpty) return books;
    
    final sortedBooks = List<Book>.from(books);
    
    sortedBooks.sort((a, b) {
        
        // 1순위: 정보 누락 여부 (Data Integrity) (오름차순: 0 < 1 < 2)
        final missingScoreA = _getIntegratedMissingScore(a);
        final missingScoreB = _getIntegratedMissingScore(b);
        if (missingScoreA != missingScoreB) {
            return missingScoreA.compareTo(missingScoreB); 
        }
        
        // 2순위: 제목 일치도 (Title Match) (내림차순: 높은 점수 우선)
        // **[수정] query 파라미터 전달**
        final titleScoreA = getTitleMatchScore(a, query); 
        final titleScoreB = getTitleMatchScore(b, query);
        if (titleScoreA != titleScoreB) {
            return titleScoreB.compareTo(titleScoreA);
        }
        
        // 3순위: 저자/출판사 일치도 (Author/Pub Match) (내림차순)
        // **[수정] query 파라미터 전달**
        final authorPubScoreA = getAuthorPublisherMatchScore(a, query); 
        final authorPubScoreB = getAuthorPublisherMatchScore(b, query);
        if (authorPubScoreA != authorPubScoreB) {
            return authorPubScoreB.compareTo(authorPubScoreA);
        }
        
        // 4순위: 평점 참여자 수 (ratingsCount) - (네이버 API에 필드 부재, 건너뜀)
        // 5순위: 평균 평점 (AverageRating) (내림차순)
        final ratingA = a.userRating ?? a.averageRating ?? 0.0; 
        final ratingB = b.userRating ?? b.averageRating ?? 0.0;
        if (ratingA != ratingB) {
            return ratingB.compareTo(ratingA); // 높은 평점 우선
        }
        
        // 6순위: 최신성 (publishedDate) (내림차순)
        final dateA = _parsePublishedDate(a.publishedDate);
        final dateB = _parsePublishedDate(b.publishedDate);
        
        if (dateA != null && dateB != null) {
            final dateCompare = dateB.compareTo(dateA); // 최신 날짜 우선
            if (dateCompare != 0) return dateCompare;
        } else if (dateB != null) { 
            return 1; 
        } else if (dateA != null) { 
            return -1; 
        } 
        
        // 최종: 제목순 (기본 정렬)
        return a.title.compareTo(b.title);
    });
    
    return sortedBooks;
  }
}