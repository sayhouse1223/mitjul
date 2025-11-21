import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/naver_search_api_service.dart';
import 'package:mitjul_app_new/features/search/widgets/book_search_result_item.dart';
import 'package:mitjul_app_new/features/search/widgets/search_bar.dart';
import 'package:mitjul_app_new/features/search/widgets/search_empty_state.dart';
import 'package:mitjul_app_new/screens/post/card_editing_screen.dart';

/// Step 3: 책 검색 화면 (포스트 등록용)
/// 
/// OCR 추출 후 책을 검색하여 선택하는 화면
/// 책 선택 시 즉시 다음 단계(카드 꾸미기)로 이동
class BookSearchScreen extends StatefulWidget {
  final String? extractedText; // OCR에서 추출된 텍스트

  const BookSearchScreen({
    super.key,
    this.extractedText,
  });

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NaverSearchApiService _apiService = NaverSearchApiService();
  List<Book> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false; // 검색을 한 번이라도 했는지 여부
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색 실행
  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _lastQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _lastQuery = query.trim();
    });

    try {
      final results = await _apiService.searchBooks(query.trim(), start: 1);
      if (mounted) {
        // SearchTab과 동일한 정렬 로직 적용
        final sortedResults = _sortBooksByPriority(results, query.trim());
        setState(() {
          _searchResults = sortedResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('검색 오류: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // ----------------------------------------------------
  // MARK: - BookSearchController와 동일한 정렬 로직
  // ----------------------------------------------------

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

  int _getIntegratedMissingScore(Book book) {
    if (_containsNoInfoText(book.title) || 
        (book.authors != null && book.authors!.any((author) => _containsNoInfoText(author))) ||
        _containsNoInfoText(book.publisher)) {
      return 2;
    }

    int generalMissingCount = 0;
    if (book.authors == null || book.authors!.isEmpty) {
      generalMissingCount++;
    }
    if (book.publisher == null || book.publisher!.isEmpty) {
      generalMissingCount++;
    }
    
    if (generalMissingCount > 0) {
      return 1;
    }
    
    return 0;
  }

  int _getTitleMatchScore(Book book, String query) {
    final lowerQuery = query.toLowerCase();
    final lowerTitle = book.title.toLowerCase().trim();
      
    if (lowerTitle == lowerQuery) {
      return 3;
    }
    if (lowerTitle.contains(lowerQuery)) {
      return 2;
    }
    return 1;
  }

  int _getAuthorPublisherMatchScore(Book book, String query) {
    final lowerQuery = query.toLowerCase();
    
    if (book.authors != null && book.authors!.any((author) => author.toLowerCase().contains(lowerQuery))) {
      return 2; 
    }
    
    if (book.publisher != null && book.publisher!.toLowerCase().contains(lowerQuery)) {
      return 2;
    }
      
    return 1;
  }

  DateTime? _parsePublishedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

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
    
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  List<Book> _sortBooksByPriority(List<Book> books, String query) {
    if (books.isEmpty) return books;
    
    final sortedBooks = List<Book>.from(books);
    
    sortedBooks.sort((a, b) {
      // 1순위: 정보 누락 여부
      final missingScoreA = _getIntegratedMissingScore(a);
      final missingScoreB = _getIntegratedMissingScore(b);
      if (missingScoreA != missingScoreB) {
        return missingScoreA.compareTo(missingScoreB); 
      }
      
      // 2순위: 제목 일치도
      final titleScoreA = _getTitleMatchScore(a, query); 
      final titleScoreB = _getTitleMatchScore(b, query);
      if (titleScoreA != titleScoreB) {
        return titleScoreB.compareTo(titleScoreA);
      }
      
      // 3순위: 저자/출판사 일치도
      final authorPubScoreA = _getAuthorPublisherMatchScore(a, query); 
      final authorPubScoreB = _getAuthorPublisherMatchScore(b, query);
      if (authorPubScoreA != authorPubScoreB) {
        return authorPubScoreB.compareTo(authorPubScoreA);
      }
      
      // 5순위: 평균 평점
      final ratingA = a.userRating ?? a.averageRating ?? 0.0; 
      final ratingB = b.userRating ?? b.averageRating ?? 0.0;
      if (ratingA != ratingB) {
        return ratingB.compareTo(ratingA);
      }
      
      // 6순위: 최신성
      final dateA = _parsePublishedDate(a.publishedDate);
      final dateB = _parsePublishedDate(b.publishedDate);
      
      if (dateA != null && dateB != null) {
        final dateCompare = dateB.compareTo(dateA);
        if (dateCompare != 0) return dateCompare;
      } else if (dateB != null) { 
        return 1; 
      } else if (dateA != null) { 
        return -1; 
      } 
      
      // 최종: 제목순
      return a.title.compareTo(b.title);
    });
    
    return sortedBooks;
  }

  /// 책 선택 시 다음 단계로 이동
  void _onBookSelected(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardEditingScreen(
          selectedBook: book,
          extractedText: widget.extractedText ?? '',
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader.sub(
        title: '책 선택',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // 검색 입력 필드
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppSearchBar(
              controller: _searchController,
              hintText: '검색어 입력',
              onSubmitted: _performSearch,
              onClear: () {
                setState(() {
                  _searchResults = [];
                  _hasSearched = false;
                });
              },
            ),
          ),

          // 검색 결과 영역
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary0,
                    ),
                  )
                : _hasSearched && _searchResults.isEmpty
                    ? const SearchEmptyState(
                        tabType: SearchTabType.book,
                      )
                    : _searchResults.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: AppColors.grayscale20,
                            ),
                            itemBuilder: (context, index) {
                              return BookSearchResultItem(
                                book: _searchResults[index],
                                onTap: _onBookSelected,
                              );
                            },
                          )
                        : const SizedBox.shrink(), // 아직 검색하지 않음
          ),
        ],
      ),
    );
  }
}