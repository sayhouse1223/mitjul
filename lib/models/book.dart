class Book {
  final String id;
  final String title;
  final String? subtitle;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? thumbnailUrl;

  Book({
    required this.id,
    required this.title,
    this.subtitle,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.thumbnailUrl,
  });

  // JSON 데이터를 Book 객체로 변환
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
    );
  }
}