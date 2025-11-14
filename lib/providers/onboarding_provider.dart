import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mitjul_app_new/models/user_profile.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/// 온보딩 플로우 상태 관리 Provider
class OnboardingProvider with ChangeNotifier {
  // Step 1: 장르 선택
  final List<String> _selectedGenres = [];
  
  // Step 2: 캐릭터 설정
  int _characterBody = -1; // 1-8
  int _characterEye = -1; // 1-4
  int _characterColor = -1; // 0-4
  
  // Step 3: 닉네임
  String _nickname = '';
  
  // 현재 스텝
  int _currentStep = 0; // 0: 장르, 1: 캐릭터, 2: 닉네임
  
  // Getters
  List<String> get selectedGenres => List.unmodifiable(_selectedGenres);
  int get characterBody => _characterBody;
  int get characterEye => _characterEye;
  int get characterColor => _characterColor;
  String get nickname => _nickname;
  int get currentStep => _currentStep;
  
  /// Step 1: 장르 토글
  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }
  
  /// Step 1: 모든 장르 선택
  void selectAllGenres(List<String> allGenres) {
    _selectedGenres.clear();
    _selectedGenres.addAll(allGenres);
    notifyListeners();
  }
  
  /// Step 1: 모든 장르 선택 해제
  void deselectAllGenres() {
    _selectedGenres.clear();
    notifyListeners();
  }
  
  /// Step 2: 캐릭터 몸 선택
  void setCharacterBody(int body) {
    _characterBody = body;
    notifyListeners();
  }
  
  /// Step 2: 캐릭터 눈 선택
  void setCharacterEye(int eye) {
    _characterEye = eye;
    notifyListeners();
  }
  
  /// Step 2: 캐릭터 색상 선택
  void setCharacterColor(int color) {
    _characterColor = color;
    notifyListeners();
  }
  
  /// Step 3: 닉네임 설정
  void setNickname(String name) {
    _nickname = name;
    notifyListeners();
  }
  
  /// 다음 스텝으로 이동
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }
  
  /// 이전 스텝으로 이동
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  /// 현재 스텝 검증
  bool canProceedFromCurrentStep() {
    switch (_currentStep) {
      case 0: // 장르 선택
        return _selectedGenres.isNotEmpty;
      case 1: // 캐릭터 설정
        return _characterBody > 0 && _characterEye > 0;
      case 2: // 닉네임
        return _nickname.trim().isNotEmpty && _nickname.trim().length >= 2;
      default:
        return false;
    }
  }
  
  /// Firebase에 사용자 프로필 저장
  Future<bool> saveUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // ⭐️ [점검 포인트 1] User 객체(uid)가 없으면 Firestore 쓰기 불가 ⭐️
      if (user == null) {
        if (kDebugMode) {
          debugPrint('❌ 사용자 프로필 저장 실패: FirebaseAuth.instance.currentUser가 null입니다. 앱 시작 시 인증(예: 익명 로그인)이 필요합니다.');
        }
        return false;
      }
      
      final profile = UserProfile(
        userId: user.uid,
        nickname: _nickname.trim(),
        favoriteGenres: _selectedGenres,
        characterBody: _characterBody,
        characterEye: _characterEye,
        characterColor: _characterColor,
        createdAt: DateTime.now(),
      );
      
      // ⭐️ [점검 포인트 2] Firestore 쓰기 작업 시도 ⭐️
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toFirestore());
      
      if (kDebugMode) {
        debugPrint('✅ 사용자 프로필 저장 완료: ${user.uid}');
      }
      
      return true;
    } catch (e) {
      // ⭐️ [점검 포인트 3] 오류 처리 ⭐️
      // (예: Firestore 권한 거부, 네트워크 오류, 데이터 형식 오류 등)
      if (kDebugMode) {
        debugPrint('❌ 사용자 프로필 저장 실패 (Firestore Write Error): $e');
      }
      return false;
    }
  }
  
  /// 온보딩 초기화
  void reset() {
    _selectedGenres.clear();
    _characterBody = 1;
    _characterEye = 1;
    _characterColor = 0;
    _nickname = '';
    _currentStep = 0;
    notifyListeners();
  }
}