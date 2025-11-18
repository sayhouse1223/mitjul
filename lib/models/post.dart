import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitjul_app_new/models/user_profile.dart';

class Post {
  final String postId;
  final UserProfile author;
  final String? quote;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
  final String sourceTitle;
  final String sourceAuthor;
  final int likesCount;

  Post({
    required this.postId,
    required this.author,
    this.quote,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    required this.sourceTitle,
    required this.sourceAuthor,
    this.likesCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'author': author.toJson(),
      'quote': quote,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'sourceTitle': sourceTitle,
      'sourceAuthor': sourceAuthor,
      'likesCount': likesCount,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    DateTime createdAt;

    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Post(
      postId: json['postId'] as String? ?? json['id'] as String? ?? '',
      author: UserProfile.fromJson(json['author'] as Map<String, dynamic>),
      quote: json['quote'] as String?,
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: createdAt,
      sourceTitle: json['sourceTitle'] as String? ?? '',
      sourceAuthor: json['sourceAuthor'] as String? ?? '',
      likesCount: json['likesCount'] as int? ?? 0,
    );
  }
}