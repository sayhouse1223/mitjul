import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/// 공통 앱 헤더 타입
enum AppHeaderType {
  main, // 메인 피드용 (로고 + 알림)
  sub,  // 서브 페이지용 (뒤로가기 + 제목 + 액션)
}

/// 공통 앱 헤더 컴포넌트
/// 
/// [Type] main | sub
/// - main: 로고+알림벨 형태 (메인 피드)
/// - sub: 뒤로가기+페이지명 형태 (진입 화면)
/// 
/// [Properties]
/// - type: 헤더 타입 (필수)
/// - title: 중앙에 표시될 페이지 이름 (sub 타입에서 사용)
/// - showLeftIcon: 좌측 아이콘 표시 여부
/// - showRightIcon: 우측 아이콘 표시 여부
/// - rightButtonText: 우측에 텍스트 버튼을 표시할 경우 (예: '다음', '게시')
/// - onLeftAction: 좌측 아이콘/버튼 클릭 시 실행될 함수
/// - onRightAction: 우측 아이콘/버튼 클릭 시 실행될 함수
/// - rightIcon: 우측에 표시할 커스텀 아이콘
/// - isRightButtonEnabled: 우측 버튼 활성화 여부
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final AppHeaderType type;
  final String? title;
  final bool showLeftIcon;
  final bool showRightIcon;
  final String? rightButtonText;
  final VoidCallback? onLeftAction;
  final VoidCallback? onRightAction;
  final IconData? rightIcon;
  final bool isRightButtonEnabled;

  const AppHeader({
    super.key,
    this.type = AppHeaderType.main,
    this.title,
    this.showLeftIcon = true,
    this.showRightIcon = true,
    this.rightButtonText,
    this.onLeftAction,
    this.onRightAction,
    this.rightIcon,
    this.isRightButtonEnabled = true,
  });

  /// Main Type 헤더 생성 (로고 + 알림)
  factory AppHeader.main({
    VoidCallback? onNotificationTap,
  }) {
    return AppHeader(
      type: AppHeaderType.main,
      onRightAction: onNotificationTap,
    );
  }

  /// Sub Type 헤더 생성 (뒤로가기 + 제목 + 액션)
  factory AppHeader.sub({
    required String title,
    VoidCallback? onBack,
    String? rightButtonText,
    IconData? rightIcon,
    VoidCallback? onRightAction,
    bool isRightButtonEnabled = true,
  }) {
    return AppHeader(
      type: AppHeaderType.sub,
      title: title,
      onLeftAction: onBack,
      rightButtonText: rightButtonText,
      rightIcon: rightIcon,
      onRightAction: onRightAction,
      isRightButtonEnabled: isRightButtonEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grayscale10,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: type == AppHeaderType.main ? _buildMainHeader(context) : _buildSubHeader(context),
        ),
      ),
    );
  }

  /// Main Type 헤더 (로고 + 알림)
  Widget _buildMainHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 로고
        SvgPicture.asset(
          'assets/images/logo.svg',
          height: 30,
        ),
        // 알림 아이콘
        if (showRightIcon)
          GestureDetector(
            onTap: onRightAction ?? () {
              debugPrint('알림 버튼 클릭');
            },
            child: SvgPicture.asset(
              'assets/icons/alram_off.svg',
              width: 28,
              height: 28,
            ),
          ),
      ],
    );
  }

  /// Sub Type 헤더 (뒤로가기 + 제목 + 액션)
  Widget _buildSubHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 좌측: 뒤로가기 버튼
        if (showLeftIcon)
          GestureDetector(
            onTap: onLeftAction ?? () => Navigator.of(context).pop(),
            child: SvgPicture.asset(
              'assets/icons/24_back.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.grayscale80,
                BlendMode.srcIn,
              ),
            ),
          )
        else
          const SizedBox(width: 24),

        // 중앙: 제목
        Expanded(
          child: Center(
            child: Text(
              title ?? '',
              style: AppTextStyles.body18R.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grayscale90,
              ),
            ),
          ),
        ),

        // 우측: 액션 버튼 (텍스트 또는 아이콘)
        if (rightButtonText != null)
          GestureDetector(
            onTap: isRightButtonEnabled ? onRightAction : null,
            child: Text(
              rightButtonText!,
              style: AppTextStyles.body16M.copyWith(
                color: isRightButtonEnabled 
                    ? AppColors.primary0 
                    : AppColors.grayscale40,
              ),
            ),
          )
        else if (rightIcon != null && showRightIcon)
          GestureDetector(
            onTap: isRightButtonEnabled ? onRightAction : null,
            child: Icon(
              rightIcon,
              size: 24,
              color: isRightButtonEnabled 
                  ? AppColors.grayscale80 
                  : AppColors.grayscale40,
            ),
          )
        else
          const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

