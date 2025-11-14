import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile.dart'; // UserProfile 모델 import

/// 앱의 게시물(피드) 정보를 나타내는 데이터 모델입니다.
class Post {
  final String postId;
  final UserProfile author; // 작성자 정보 (UserProfile 객체)
  final String content; // 게시물 본문 (글)
  final String? imageUrl; // 첨부된 이미지 URL (선택 사항)
  final String category; // 게시물 카테고리 (예: '책', '영화', '음악', '일반')
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  
  // 미툴 앱의 특성을 고려한 필드 추가
  final String? sourceTitle; // 원본 출처 제목 (예: 책 제목, 영화 제목)
  final String? sourceAuthor; // 원본 출처 작가/감독 등

  Post({
    required this.postId,
    required this.author,
    required this.content,
    required this.category,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.sourceTitle,
    this.sourceAuthor,
  });

  /// Firestore Map 데이터로부터 Post 객체를 생성하는 팩토리 메서드입니다.
  factory Post.fromJson(Map<String, dynamic> json) {
    // Firestore Timestamp를 DateTime으로 변환
    DateTime timestamp = (json['createdAt'] as Timestamp).toDate();

    return Post(
      postId: json['postId'] as String,
      // 'author' 필드는 Map<String, dynamic>이며, 이를 UserProfile.fromJson으로 변환합니다.
      author: UserProfile.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: timestamp,
      sourceTitle: json['sourceTitle'] as String?,
      sourceAuthor: json['sourceAuthor'] as String?,
    );
  }

  /// Post 객체를 Firestore에 저장할 수 있는 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      // author 객체를 to Map으로 변환하여 중첩된 데이터로 저장
      'author': author.toJson(), 
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': FieldValue.serverTimestamp(), // 서버 타임스탬프를 사용하여 정확한 생성 시간 기록
      'sourceTitle': sourceTitle,
      'sourceAuthor': sourceAuthor,
    };
  }
}