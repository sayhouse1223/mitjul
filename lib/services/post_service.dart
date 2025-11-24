import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mitjul_app_new/models/post.dart'; // 기존 post.dart 파일 사용
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/models/user_profile.dart'; // UserProfile 모델 필요
import 'package:mitjul_app_new/services/local_post_storage.dart'; // 로컬 저장소

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  /// 카드 이미지와 함께 포스팅 생성 (새로운 플로우용)
  /// Firebase 유료 플랜 필요 - 임시로 로컬 저장만 수행
  Future<void> createPostWithImage({
    required File cardImageFile,
    required String caption,
    required String extractedText,
    required Book book,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('사용자가 인증되지 않았습니다.');
    }

    // 임시 사용자 프로필 생성 (로컬용)
    final authorProfile = UserProfile(
      userId: user.uid,
      nickname: '임시사용자',
      profileImageUrl: '',
      bio: '',
      isOnboardingCompleted: false,
    );

    // 로컬 저장소에 포스트 저장
    LocalPostStorage().addPost(
      cardImagePath: cardImageFile.path,
      caption: caption,
      extractedText: extractedText,
      book: book,
      author: authorProfile,
    );
    
    print('📝 [로컬] 포스팅 정보:');
    print('  - 책: ${book.title}');
    print('  - 인용: $extractedText');
    print('  - 감상: $caption');
    print('  - 이미지 경로: ${cardImageFile.path}');
    
    // 짧은 딜레이 (실제 저장하는 것처럼 보이게)
    await Future.delayed(const Duration(seconds: 1));
    
    print('✅ [로컬] 포스팅 완료');
    print('💡 실제 Firebase 연동 시 Storage + Firestore에 저장됩니다.');
    
    // 실제 Firebase 연동 코드 (주석 처리)
    /*
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('사용자가 인증되지 않았습니다. 로그인이 필요합니다.');
    }

    // 1. 현재 사용자 프로필 가져오기
    final userProfileDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userProfileDoc.exists || userProfileDoc.data() == null) {
      throw Exception('사용자 프로필을 찾을 수 없습니다.');
    }
    final authorProfile = UserProfile.fromJson(userProfileDoc.data()!);

    // 2. Firebase Storage에 이미지 업로드
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${user.uid}_$timestamp.png';
    final storageRef = _storage.ref().child('posts/$fileName');
    
    final uploadTask = await storageRef.putFile(cardImageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // 3. Post 모델 객체 생성
    final newPost = Post(
      postId: 'temp_id',
      author: authorProfile,
      quote: extractedText,
      content: caption,
      category: '도서',
      imageUrl: downloadUrl,
      createdAt: DateTime.now(),
      sourceTitle: book.title,
      sourceAuthor: book.authors?.join(', ') ?? '저자 정보 없음',
    );

    // 4. Firestore에 저장
    final docRef = await _firestore.collection('posts').add(newPost.toJson());
    await docRef.update({'postId': docRef.id});

    print('✅ 포스팅이 성공적으로 저장되었습니다. ID: ${docRef.id}');
    */
  }

  // TODO: 이후 포스팅 목록을 가져오거나, 좋아요를 처리하는 메서드가 여기에 추가됩니다.
}