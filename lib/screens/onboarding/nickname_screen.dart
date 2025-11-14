import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
// dart:async 임포트와 _debounceTimer를 제거합니다.
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/providers/onboarding_provider.dart';
import 'package:mitjul_app_new/utils/character_utils.dart';
import 'package:mitjul_app_new/screens/home/home_screen.dart';
// index.dart 하나로 통합
import 'package:mitjul_app_new/components/index.dart'; 

/// Step 3: 닉네임 입력 화면
class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;
  // 닉네임 중복 확인 및 유효성 상태 변수
  bool _isCheckingNickname = false;
  bool _isNicknameAvailable = true; // 닉네임 사용 가능 여부
  String? _nicknameErrorText; // 노출할 오류 메시지
  
  // 닉네임 최대 길이를 상수로 정의
  static const int maxNicknameLength = 12;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
  
  // [REFINED] 닉네임 중복 확인 실제 Firestore 연동 함수 (UI 상태 변경 로직 제거)
  Future<bool> _checkNicknameAvailability(String nickname) async {
    final firestore = FirebaseFirestore.instance;
    
    try {
      final querySnapshot = await firestore
          .collection('users') 
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty; 

    } catch (e) {
      debugPrint('Firestore Nickname Check Error: $e');
      if (!mounted) return false;
      setState(() {
        // 오류가 발생하면 텍스트 필드 아래에 오류 메시지를 표시합니다.
        _nicknameErrorText = '닉네임 확인 중 오류가 발생했습니다.';
      });
      return false; 
    }
  }

  // ⭐️ [MAJOR CHANGE] _completeOnboarding: 완료 버튼 클릭 시 모든 유효성 검사 수행 ⭐️
  Future<void> _completeOnboarding() async {
    final provider = context.read<OnboardingProvider>();
    final nickname = _nicknameController.text.trim();
    
    // 1. 초기 상태 리셋 및 기본 유효성 검사 (길이)
    if (nickname.isEmpty || nickname.length < 2) {
      // 닉네임이 짧거나 비어있으면 오류 메시지 표시
      setState(() {
        _nicknameErrorText = '닉네임은 2자 이상 입력해주세요.';
        _isNicknameAvailable = false; // 버튼 비활성화를 위해
      });
      return;
    }
    
    // 2. 중복 확인 시작 UI 로딩 상태 표시
    setState(() {
      _isCheckingNickname = true;
      _isLoading = true; // 버튼 자체 로딩 시작
      _isNicknameAvailable = false; // 확인 중이므로 일단 불가능 상태
      _nicknameErrorText = '닉네임 중복 확인 중...'; // 안내 문구 변경
    });
    
    // 3. 실제 Firestore 중복 확인 실행
    final isAvailable = await _checkNicknameAvailability(nickname);
    
    if (!mounted) return;
    
    // 4. 중복 확인 결과에 따른 상태 업데이트 및 진행 결정
    if (!isAvailable) {
      // 중복 발견 -> 완료 진행 불가
      setState(() {
        _isCheckingNickname = false;
        _isLoading = false;
        _isNicknameAvailable = false; 
        _nicknameErrorText = '이미 이용 중인 닉네임입니다.'; // 최종 오류 메시지
      });
      _showSnackBar('이미 이용 중인 닉네임입니다. 다른 닉네임을 선택해주세요.');
      return;
    }
    
    // 5. 중복 확인 통과 -> 온보딩 저장 진행
    // UI 상태 업데이트 (로딩 유지)
    setState(() {
      _isCheckingNickname = false;
      _isNicknameAvailable = true; // 사용 가능 상태로 변경
      _nicknameErrorText = '사용 가능한 닉네임입니다.'; // 최종 안내 메시지
      // _isLoading = true; // 이미 켜져 있음
    });
    
    // 닉네임 설정 및 Firebase에 저장
    provider.setNickname(nickname);
    final success = await provider.saveUserProfile();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (success) {
      // 홈 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      // 저장 실패 시 오류 상태 리셋
      setState(() {
        _nicknameErrorText = '회원가입에 실패했습니다. 다시 시도해주세요.';
        _isNicknameAvailable = false; // 버튼 다시 비활성화
      });
      _showSnackBar('회원가입에 실패했습니다. 다시 시도해주세요.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.point1Error,
      ),
    );
  }
  
  // ⭐️ [REFINED] _onNicknameChanged: 길이 제한 및 기본 안내 문구만 처리 ⭐️
  void _onNicknameChanged(String value) {
    final trimmedValue = value.trim();
    
    // 1. 길이 제한 적용
    if (value.length > maxNicknameLength) {
      _nicknameController.text = value.substring(0, maxNicknameLength);
      // 커서를 끝으로 이동 (포커싱 유지)
      _nicknameController.selection = TextSelection.fromPosition(
          TextPosition(offset: _nicknameController.text.length));
      return;
    }
    
    // 2. 닉네임이 변경되면 이전의 유효성 검사 결과를 초기화
    if (trimmedValue.length < 2) {
      setState(() {
        _isNicknameAvailable = false; // 2자 미만이면 사용 불가 상태
        _isCheckingNickname = false; 
        _nicknameErrorText = '2-12자, 한글/영문/숫자 사용 가능'; // 기본 안내 문구 (회색)
      });
    } else if (trimmedValue.length >= 2) {
      // 2자 이상 입력되었을 때: 이전의 성공/실패 상태를 리셋하고 기본 안내 문구 표시
      // 버튼을 누르기 전까지는 중립 상태(회색)를 유지해야 합니다.
      setState(() {
        _isNicknameAvailable = false; // (버튼 비활성화를 위해 false 유지)
        _isCheckingNickname = false; 
        _nicknameErrorText = null; // null로 설정하여 build에서 중립 안내 문구('2-12자, ...')가 표시되도록 함
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final nickname = _nicknameController.text.trim();
    
    // 버튼 활성화 조건: 닉네임 2자 이상, 로딩/확인 중 아님
    final isNicknameValidForCompletion = 
        nickname.length >= 2 && 
        !_isLoading &&
        !_isCheckingNickname;
    
    // ⭐️ [FIX] 안내 문구 색상 로직 수정: 명시적인 오류/성공 상태가 아닐 경우 무조건 회색으로 처리 ⭐️
    Color infoColor;
    
    // 1. 확인/저장 중일 때 (회색)
    if (_isCheckingNickname || _isLoading) {
        infoColor = AppColors.grayscale60;
    // 2. 닉네임이 사용 가능으로 최종 확인된 상태일 때 (파란색)
    } else if (nickname.length >= 2 && _isNicknameAvailable) {
        infoColor = AppColors.primary0; 
    // 3. _nicknameErrorText가 있고, 그 내용이 기본 안내 문구가 아닐 때 (빨간색 - 완료 버튼 눌러서 생긴 오류)
    } else if (_nicknameErrorText != null && 
               _nicknameErrorText != '2-12자, 한글/영문/숫자 사용 가능') {
        infoColor = AppColors.point1Error; 
    // 4. 그 외 (2자 미만 초기 상태, 2자 이상 입력 후 중립 상태) (회색)
    } else {
        infoColor = AppColors.grayscale60; 
    }
    
    // 표시할 안내 문구
    String displayInfoText;
    if (_isCheckingNickname || _isLoading) {
      displayInfoText = '진행 중...'; // '닉네임 중복 확인 중...' 또는 '저장 중...'
    } else if (_nicknameErrorText != null) {
        displayInfoText = _nicknameErrorText!;
    } else {
        displayInfoText = '2-12자, 한글/영문/숫자 사용 가능';
    }


    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // 타이틀
              Text(
                '닉네임을 입력해주세요',
                style: AppTextStyles.header.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 캐릭터 미리보기
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CharacterColors.getBackgroundColor(provider.characterColor),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 캐릭터 몸 (2.4배 확대)
                          Transform.scale(
                            scale: 2.4,
                            child: SvgPicture.asset(
                              CharacterAssets.getBodyPath(provider.characterBody),
                              width: 60,
                              height: 60,
                              colorFilter: ColorFilter.mode(
                                CharacterColors.getColor(provider.characterColor),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          // 캐릭터 눈 (2.4배 확대)
                          Transform.scale(
                            scale: 2.4,
                            child: SvgPicture.asset(
                              CharacterAssets.getEyePath(provider.characterEye),
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // 닉네임 입력 필드 (AppTextField 적용)
              AppTextField(
                controller: _nicknameController,
                hintText: '닉네임을 입력하세요',
                // 오른쪽 끝에 시스템 텍스트 '님' 노출
                suffixType: InputSuffixType.systemText,
                suffixText: '님', 
                
                // 로딩 중에는 입력 필드 비활성화
                enabled: !_isLoading && !_isCheckingNickname, 
                isRightAligned: false, // 사용자 입력은 왼쪽 정렬
                onChanged: _onNicknameChanged,
                onSubmitted: (_) => _completeOnboarding(),
              ),
              
              const SizedBox(height: 8),
              
              // [NEW] 안내 문구 및 오류 메시지
              // 로딩/확인 중일 때만 스피너 표시
              if ((_isCheckingNickname || _isLoading) && nickname.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: infoColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayInfoText, // '닉네임 중복 확인 중...' 또는 '저장 중...'
                        style: AppTextStyles.caption12R.copyWith(color: infoColor),
                      ),
                    ],
                  ),
                )
              else 
                // 안내 문구
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      displayInfoText,
                      style: AppTextStyles.caption12R.copyWith(
                        color: infoColor, // 닉네임 상태에 따라 색상 자동 변경
                      ),
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // 하단 버튼 (AppButton 사용)
              Row(
                children: [
                  // 이전 버튼
                  Expanded(
                    child: AppButton(
                      label: '이전',
                      onPressed: _isLoading || _isCheckingNickname
                          ? null
                          : () {
                              final provider = context.read<OnboardingProvider>();
                              provider.previousStep();
                            },
                      type: ButtonType.primaryLine, 
                      isLarge: true,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 완료 버튼
                  Expanded(
                    child: AppButton(
                      label: '완료',
                      // 버튼 활성화: 닉네임 2자 이상이고, 확인/저장 중이 아닐 때만 활성화
                      onPressed: isNicknameValidForCompletion
                          ? _completeOnboarding 
                          : null, 
                      type: ButtonType.primaryFill,
                      isLarge: true,
                      // 로딩 스피너는 중복 확인 및 저장(_isLoading, _isCheckingNickname) 모두 포함
                      isLoading: _isLoading || _isCheckingNickname, 
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}