class Book {
  final String id;
  final String title;
  final String? subtitle;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? thumbnailUrl;
  final int? ratingsCount;
  final double? averageRating;
  final double? userRating; // Naver API의 userRating (평점)

  Book({
    required this.id,
    required this.title,
    this.subtitle,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.thumbnailUrl,
    this.ratingsCount,
    this.averageRating,
    this.userRating,
  });

  // Google Books API JSON 데이터를 Book 객체로 변환
  factory Book.fromJson(Map<String, dynamic> json) {
    // Google Books API 응답 구조를 기반으로 파싱
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>? ?? {};

    return Book(
      id: json['id'] ?? 'unknown_id',
      title: volumeInfo['title'] ?? '제목 없음',
      subtitle: volumeInfo['subtitle'],
      // authors는 List<dynamic>으로 올 수 있으므로 List<String>으로 변환
      authors: (volumeInfo['authors'] as List<dynamic>?)?.cast<String>(),
      publisher: volumeInfo['publisher'],
      publishedDate: volumeInfo['publishedDate'],
      description: volumeInfo['description'],
      // 썸네일 URL을 가져옵니다.
      thumbnailUrl: imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'],
      // 평점 정보
      ratingsCount: volumeInfo['ratingsCount'] as int?,
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble(),
      userRating: null, // Google Books API에는 userRating이 없음
    );
  }

  // Naver Search API JSON 데이터를 Book 객체로 변환
  factory Book.fromNaverJson(Map<String, dynamic> json) {
    // HTML 태그 제거 헬퍼 함수
    String removeHtmlTags(String? text) {
      if (text == null || text.isEmpty) return '';
      return text
          .replaceAll(RegExp(r'<[^>]*>'), '') // HTML 태그 제거
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .trim();
    }

    // 저자 파싱 (파이프(|)로 구분, 여러 구분자 지원)
    List<String>? parseAuthors(String? authorString) {
      if (authorString == null || authorString.isEmpty) return null;
      
      // 여러 구분자로 분리 시도: |, ^, / 등
      String normalized = authorString;
      // ^ 문자를 |로 변환 (일부 API 응답에서 사용)
      normalized = normalized.replaceAll('^', '|');
      // 슬래시를 파이프로 변환 (일관성을 위해)
      normalized = normalized.replaceAll(RegExp(r'\s*/\s*'), '|');
      
      final authors = normalized
          .split('|')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();
      
      return authors.isEmpty ? null : authors;
    }

    // 출판일 파싱 (YYYYMMDD -> YYYY-MM-DD)
    String? parsePublishedDate(String? pubdate) {
      if (pubdate == null || pubdate.isEmpty) return null;
      if (pubdate.length == 8) {
        // YYYYMMDD 형식
        return '${pubdate.substring(0, 4)}-${pubdate.substring(4, 6)}-${pubdate.substring(6, 8)}';
      }
      return pubdate;
    }

    // userRating 파싱 (문자열 또는 숫자로 올 수 있음)
    double? parseUserRating(dynamic rating) {
      if (rating == null) return null;
      if (rating is num) return rating.toDouble();
      if (rating is String) {
        final parsed = double.tryParse(rating);
        return parsed;
      }
      return null;
    }

    // 제목에서 부제목 분리 (Naver API는 title에 부제목이 포함될 수 있음)
    String? parseSubtitle(String? title) {
      if (title == null || title.isEmpty) return null;
      // 제목에 괄호가 있으면 부제목으로 추출 시도
      final match = RegExp(r'[\(（]([^\)）]+)[\)）]').firstMatch(title);
      if (match != null) {
        return match.group(1)?.trim();
      }
      return null;
    }

    final titleText = removeHtmlTags(json['title']) ?? '제목 없음';
    final extractedSubtitle = parseSubtitle(titleText);
    final cleanTitle = extractedSubtitle != null
        ? titleText.replaceAll(RegExp(r'[\(（][^\)）]+[\)）]'), '').trim()
        : titleText;

    return Book(
      id: json['isbn'] ?? json['link'] ?? 'unknown_id', // ISBN을 ID로 사용, 없으면 link 사용
      title: cleanTitle,
      subtitle: extractedSubtitle, // 제목에서 추출한 부제목
      authors: parseAuthors(json['author']),
      publisher: removeHtmlTags(json['publisher']),
      publishedDate: parsePublishedDate(json['pubdate']),
      description: removeHtmlTags(json['description']),
      thumbnailUrl: json['image'],
      // Naver API 평점 정보
      ratingsCount: null,
      averageRating: null,
      userRating: parseUserRating(json['userRating']), // Naver API의 userRating 필드
    );
  }
}