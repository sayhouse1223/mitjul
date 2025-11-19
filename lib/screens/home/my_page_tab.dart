import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/services/auth_service.dart';

class MyPageTab extends StatelessWidget {
  const MyPageTab({super.key}); 

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAnonymous = authService.isAnonymous;

    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: isAnonymous ? _buildAnonymousUserView(context) : _buildMemberUserView(context),
      ),
    );
  }

  // 비회원 화면
  Widget _buildAnonymousUserView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '마이페이지',
            style: AppTextStyles.header.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 40),
          // 비회원 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grayscale10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '비회원으로 이용 중입니다',
                  style: AppTextStyles.body16M.copyWith(
                    color: AppColors.grayscale80,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '회원가입을 하시면 더 많은 기능을 이용하실 수 있습니다.',
                  style: AppTextStyles.body14R.copyWith(
                    color: AppColors.grayscale60,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 회원가입 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 회원가입 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('회원가입 기능은 준비 중입니다.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary0,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '회원가입하기',
                style: AppTextStyles.body16M.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: 로그인 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인 기능은 준비 중입니다.')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary0,
                side: const BorderSide(color: AppColors.primary0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '로그인하기',
                style: AppTextStyles.body16M.copyWith(
                  color: AppColors.primary0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 회원 화면
  Widget _buildMemberUserView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            '마이페이지',
            style: AppTextStyles.header.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 40),
          // 회원 정보 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grayscale10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '회원 정보',
                  style: AppTextStyles.body16M.copyWith(
                    color: AppColors.grayscale80,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '회원으로 로그인되어 있습니다.',
                  style: AppTextStyles.body14R.copyWith(
                    color: AppColors.grayscale60,
                  ),
                ),
                // TODO: 실제 회원 정보 표시 (닉네임, 프로필 이미지 등)
              ],
            ),
          ),
          const Spacer(),
          // 로그아웃 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final authService = AuthService();
                await authService.signOut();
                // TODO: 로그인 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃되었습니다.')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.point1Error,
                side: const BorderSide(color: AppColors.point1Error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '로그아웃',
                style: AppTextStyles.body16M.copyWith(
                  color: AppColors.point1Error,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}