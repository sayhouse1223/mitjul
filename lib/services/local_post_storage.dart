import 'dart:io';
import 'package:mitjul_app_new/models/post.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/models/user_profile.dart';

/// 임시 포스트 저장소 (메모리)
/// Firebase 연동 전까지 사용
class LocalPostStorage {
  static final LocalPostStorage _instance = LocalPostStorage._internal();
  factory LocalPostStorage() => _instance;
  LocalPostStorage._internal();

  // 메모리에 저장된 포스트 목록
  final List<Post> _posts = [];

  // 임시 이미지 파일 경로 저장
  final Map<String, String> _imageFilePaths = {};

  /// 포스트 추가
  void addPost({
    required String cardImagePath,
    required String caption,
    required String extractedText,
    required Book book,
    required UserProfile author,
  }) {
    final postId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newPost = Post(
      postId: postId,
      author: author,
      quote: extractedText,
      content: caption,
      category: '도서',
      imageUrl: book.thumbnailUrl, // 임시로 책 썸네일 사용
      createdAt: DateTime.now(),
      sourceTitle: book.title,
      sourceAuthor: book.authors?.join(', ') ?? '저자 정보 없음',
    );

    _posts.insert(0, newPost); // 최신 포스트가 위로
    _imageFilePaths[postId] = cardImagePath; // 이미지 파일 경로 저장

    print('📝 [로컬] 포스트 저장 완료: $postId');
  }

  /// 모든 포스트 가져오기
  List<Post> getAllPosts() {
    return List.unmodifiable(_posts);
  }

  /// 포스트의 로컬 이미지 경로 가져오기
  String? getLocalImagePath(String postId) {
    return _imageFilePaths[postId];
  }

  /// 모든 포스트 삭제 (테스트용)
  void clearAll() {
    _posts.clear();
    _imageFilePaths.clear();
    print('🗑️ [로컬] 모든 포스트 삭제됨');
  }
}

