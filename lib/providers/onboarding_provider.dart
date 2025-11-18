import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mitjul_app_new/models/user_profile.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/// 온보딩 플로우 상태 관리 Provider
class OnboardingProvider with ChangeNotifier {
  // === 온보딩 핵심 상태 ===
  bool _isOnboardingCompleted = false; // ⭐️ 앱 라우팅에 사용될 핵심 상태 ⭐️

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
  bool get isOnboardingCompleted => _isOnboardingCompleted; // ⭐️ 라우팅용 Getter ⭐️
  
  // 현재 사용자 ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  DocumentReference? get _profileRef {
    final userId = _userId;
    if (userId == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(userId);
  }

  // === ⭐️ 핵심 로직 1: 온보딩 상태 로드 ⭐️ ===
  /// 앱 시작 시 Firestore에서 온보딩 완료 상태를 로드합니다.
  Future<void> loadOnboardingStatus() async {
    final profileRef = _profileRef;
    if (profileRef == null) {
      if (kDebugMode) debugPrint('🚨 사용자 ID를 찾을 수 없습니다. 온보딩 상태 로드 불가.');
      _isOnboardingCompleted = false;
      notifyListeners();
      return;
    }

    try {
      final snapshot = await profileRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        
        // Firestore 필드에서 'isOnboardingCompleted' 플래그를 확인합니다.
        _isOnboardingCompleted = data?['isOnboardingCompleted'] ?? false;
        
        if (kDebugMode) {
          debugPrint('✅ 온보딩 상태 로드 완료: $_isOnboardingCompleted');
        }
      } else {
        // 문서가 없으면 처음 접속한 것으로 간주하고 false 유지
        _isOnboardingCompleted = false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 온보딩 상태 로드 중 오류 발생: $e');
      _isOnboardingCompleted = false; // 오류 시 온보딩으로 이동
    }
    
    // AuthWrapper가 상태 변화를 감지하도록 알립니다.
    notifyListeners(); 
  }
  
  // Step 1: 장르 토글
  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }
  
  // Step 1: 모든 장르 선택
  void selectAllGenres(List<String> allGenres) {
    _selectedGenres.clear();
    _selectedGenres.addAll(allGenres);
    notifyListeners();
  }
  
  // Step 1: 모든 장르 선택 해제
  void deselectAllGenres() {
    _selectedGenres.clear();
    notifyListeners();
  }
  
  // Step 2: 캐릭터 몸 선택
  void setCharacterBody(int body) {
    _characterBody = body;
    notifyListeners();
  }
  
  // Step 2: 캐릭터 눈 선택
  void setCharacterEye(int eye) {
    _characterEye = eye;
    notifyListeners();
  }
  
  // Step 2: 캐릭터 색상 선택
  void setCharacterColor(int color) {
    _characterColor = color;
    notifyListeners();
  }
  
  // Step 3: 닉네임 설정
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
  
  /// Firebase에 사용자 프로필 저장 및 완료 상태 업데이트
  Future<bool> saveUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        if (kDebugMode) debugPrint('❌ 사용자 프로필 저장 실패: 사용자 인증 정보 없음.');
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
        // ⭐️ 핵심: 완료 플래그 추가 ⭐️
        isOnboardingCompleted: true, 
      );
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toFirestore());
      
      // 로컬 상태 업데이트
      _isOnboardingCompleted = true;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ 사용자 프로필 저장 및 온보딩 완료 처리: ${user.uid}');
      }
      
      return true;
    } catch (e) {
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
    _isOnboardingCompleted = false; // 초기화 시 완료 상태도 리셋
    notifyListeners();
  }
}