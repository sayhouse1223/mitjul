import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 사용자
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 구글 로그인 (개발용 - 시뮬레이터/웹)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      
      if (kIsWeb) {
        // 웹: 팝업
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // iOS 시뮬레이터: redirect
        return await _auth.signInWithProvider(googleProvider);
      }
    } catch (e) {
      print('구글 로그인 에러: $e');
      return null;
    }
  }

  // 비회원(익명) 로그인
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('익명 로그인 성공: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('익명 로그인 에러: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 사용자가 익명 로그인 상태인지 확인
  bool get isAnonymous => currentUser?.isAnonymous ?? false;
}
