import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/services/auth_service.dart';
import 'package:mitjul_app_new/screens/home/home_screen.dart';
import 'package:mitjul_app_new/services/auth_service.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 & 타이틀
              Column(
                children: [
                  /*Text(
                    '밑줄',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary0,
                      letterSpacing: 2,
                    ), */
                    Image.asset(
                    'assets/images/logo.png', // 이미지 경로를 정확히 지정합니다.
                    width: 100, // 로고 이미지의 너비를 조정 (필요에 따라 조절)
                    height: 37, // 로고 이미지의 높이를 조정 (필요에 따라 조절)
                    // fit: BoxFit.contain, // 이미지 비율 유지하며 컨테이너에 맞춤
                  ),
                  /*
                  SizedBox(height: 12),
                  Text(
                    '문장과 문장 사이',
                    style: AppTextStyles.body16R.copyWith(
                      color: AppColors.grayscale60,
                    ),
                  ), 
                  */
                ],
              ),
              
              SizedBox(height: 80),
              
              // 소셜 로그인 버튼들
              _SocialLoginButton(
                text: '카카오로 시작하기',
                backgroundColor: Color(0xFFFFE812),
                textColor: Color(0xFF191919),
                onTap: () {
                  // TODO: 카카오 로그인
                  print('카카오 로그인');
                },
              ),
              
              SizedBox(height: 12),
              
              _SocialLoginButton(
                text: '네이버로 시작하기',
                backgroundColor: Color(0xFF03C75A),
                textColor: Colors.white,
                onTap: () {
                  // TODO: 네이버 로그인
                  print('네이버 로그인');
                },
              ),
              
              SizedBox(height: 12),
              _SocialLoginButton(
                text: 'Google로 시작하기',
                backgroundColor: Colors.white,
                textColor: Color(0xFF191919),
                borderColor: AppColors.grayscale30,
                onTap: () async {
                    final authService = AuthService();
                    final result = await authService.signInWithGoogle();
                    
                    if (result != null) {
                    // 로그인 성공!
                    print('로그인 성공: ${result.user?.email}');
                    // TODO: 홈 화면으로 이동
                    } else {
                    // 로그인 실패 또는 취소
                    print('로그인 실패');
                    }
                },
                ),

              
              SizedBox(height: 12),
              
              _SocialLoginButton(
                text: 'Apple로 시작하기',
                backgroundColor: Color(0xFF000000),
                textColor: Colors.white,
                onTap: () {
                  // TODO: 애플 로그인
                  print('애플 로그인');
                },
              ),
              
              SizedBox(height: 32),
              
              // 비회원으로 시작하기
              TextButton(
                onPressed: () async {
                  // 로딩 표시 
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // 익명 로그인 실행
                  final userCredential = await AuthService().signInAnonymously();
                  
                  // 로딩 닫기
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  // 로그인 성공 시 홈 화면으로 이동
                  if (userCredential != null && context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else {
                    // 에러 처리
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인에 실패했습니다.')),
                      );
                    }
                  }
                },
                child: Text(
                  '비회원으로 시작하기',
                  style: AppTextStyles.body16M.copyWith(
                    color: AppColors.grayscale60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 소셜 로그인 버튼 위젯
class _SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.body16M.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
