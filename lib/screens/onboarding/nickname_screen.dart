import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/providers/onboarding_provider.dart';
import 'package:mitjul_app_new/utils/character_utils.dart';
import 'package:mitjul_app_new/screens/home/home_screen.dart';

/// Step 3: 닉네임 입력 화면
class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final provider = context.read<OnboardingProvider>();
    
    // 닉네임 유효성 검사
    if (_nicknameController.text.trim().isEmpty) {
      _showSnackBar('닉네임을 입력해주세요');
      return;
    }
    
    if (_nicknameController.text.trim().length < 2) {
      _showSnackBar('닉네임은 최소 2글자 이상이어야 합니다');
      return;
    }
    
    setState(() => _isLoading = true);
    
    // 닉네임 설정
    provider.setNickname(_nicknameController.text.trim());
    
    // Firebase에 저장
    final success = await provider.saveUserProfile();
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      // 홈 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
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

  @override
  Widget build(BuildContext context) {
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
                          // 캐릭터 몸 (1.8배 확대)
                          Transform.scale(
                            scale: 1.8,
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
                          // 캐릭터 눈 (1.8배 확대)
                          Transform.scale(
                            scale: 1.8,
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
              
              // 닉네임 입력 필드
              TextField(
                controller: _nicknameController,
                maxLength: 12,
                textAlign: TextAlign.center,
                style: AppTextStyles.body16M,
                decoration: InputDecoration(
                  hintText: '닉네임을 입력하세요',
                  hintStyle: AppTextStyles.body16R.copyWith(
                    color: AppColors.grayscale40,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.grayscale10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary0,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // 버튼 상태 업데이트
                },
                onSubmitted: (_) => _completeOnboarding(),
              ),
              
              const SizedBox(height: 8),
              
              // 안내 문구
              Text(
                '2-12자, 한글/영문/숫자 사용 가능',
                style: AppTextStyles.caption12R.copyWith(
                  color: AppColors.grayscale60,
                ),
              ),
              
              const Spacer(),
              
              // 하단 버튼
              Row(
                children: [
                  // 이전 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final provider = context.read<OnboardingProvider>();
                              provider.previousStep();
                            },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppColors.primary0.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '이전',
                        style: AppTextStyles.body16M.copyWith(
                          color: AppColors.primary0,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 완료 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || _nicknameController.text.trim().length < 2
                          ? null
                          : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: _nicknameController.text.trim().length >= 2
                            ? AppColors.primary0
                            : AppColors.grayscale20,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              '완료',
                              style: AppTextStyles.body16M.copyWith(
                                color: Colors.white,
                              ),
                            ),
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