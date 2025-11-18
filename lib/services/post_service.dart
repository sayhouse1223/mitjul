import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mitjul_app_new/models/post.dart'; // 기존 post.dart 파일 사용
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/models/user_profile.dart'; // UserProfile 모델 필요

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 포스팅을 Firestore에 저장하는 메서드
  Future<void> createPost({
    required String quote,
    required String review,
    required Book book,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('사용자가 인증되지 않았습니다. 로그인이 필요합니다.');
    }

    // 1. 현재 사용자 프로필 데이터 가져오기 (Post 모델의 author 필드에 필요)
    // Firestore 'users' 컬렉션에서 현재 사용자의 프로필 문서를 조회합니다.
    final userProfileDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userProfileDoc.exists || userProfileDoc.data() == null) {
       throw Exception('사용자 프로필을 찾을 수 없습니다.');
    }
    
    // UserProfile.fromJson 팩토리 메서드를 사용하여 UserProfile 객체 생성
    final authorProfile = UserProfile.fromJson(userProfileDoc.data()!);

    // 2. Post 모델 객체 생성 및 Book 정보 매핑
    final newPost = Post(
      postId: 'temp_id', // Firestore에 추가(add)할 때 실제 ID로 업데이트할 예정
      author: authorProfile,
      quote: quote,
      content: review, // review를 content 필드에 매핑
      category: '도서', // 카테고리 명시
      imageUrl: book.thumbnailUrl, // 책 썸네일을 imageUrl에 매핑
      createdAt: DateTime.now(),
      sourceTitle: book.title, // 책 제목을 sourceTitle에 매핑
      sourceAuthor: book.authors?.join(', ') ?? '저자 정보 없음', // 저자를 sourceAuthor에 매핑
    );

    try {
      // 'posts' 컬렉션에 새 문서 추가. add() 사용 시 ID는 자동으로 생성됩니다.
      final docRef = await _firestore.collection('posts').add(newPost.toJson());
      
      // PostId 필드를 생성된 Firestore 문서 ID로 업데이트
      await docRef.update({'postId': docRef.id});
      
      print('✅ 포스팅이 성공적으로 저장되었습니다. ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      print('❌ Firestore 포스팅 저장 오류: ${e.message}');
      throw Exception('포스팅 저장에 실패했습니다. (${e.code}) 다시 시도해 주세요.');
    } catch (e) {
      print('❌ 기타 오류: $e');
      rethrow;
    }
  }

  // TODO: 이후 포스팅 목록을 가져오거나, 좋아요를 처리하는 메서드가 여기에 추가됩니다.
}