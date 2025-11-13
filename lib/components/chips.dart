import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';


// 칩의 스타일 (배경 채움 vs 경계선)
enum ChipStyle { fill, line }

// 칩의 사이즈 (Large vs Small)
enum ChipSize { large, small }

// ------------------------------------------------------------------
// 1. 범용적인 AppChip 위젯 (Fill/Line, Large/Small)
// ------------------------------------------------------------------

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ChipStyle style;
  final ChipSize size;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.style = ChipStyle.line, // 기본값: Line 스타일
    this.size = ChipSize.large,  // 기본값: Large 사이즈
  });

  @override
  Widget build(BuildContext context) {
    // 1. 사이즈별 패딩 및 폰트 크기 결정
    final double verticalPadding = size == ChipSize.large ? 8 : 4; // chip 가로 여백
    final double horizontalPadding = size == ChipSize.large ? 20 : 12; // chip 세로 여백
    final TextStyle textStyle = size == ChipSize.large ? AppTextStyles.body16R : AppTextStyles.body14R;
    final double borderRadius = size == ChipSize.large ? 24 : 28;

    // 2. 스타일 및 선택 상태별 색상/경계선 결정
    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    if (style == ChipStyle.fill) {
      // Fill 스타일
      backgroundColor = isSelected ? AppColors.primary0 : AppColors.grayscale10;
      borderColor = isSelected ? AppColors.primary0 : AppColors.grayscale10;
      textColor = isSelected ? Colors.white : AppColors.textPrimary;
    } else {
      // Line 스타일 (기존 장르칩 스타일)
      backgroundColor = isSelected ? AppColors.primaryMinus30 : AppColors.background;
      borderColor = isSelected ? AppColors.primary0 : AppColors.grayscale30;
      textColor = isSelected ? AppColors.primary0 : AppColors.textPrimary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: textStyle.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// 2. 모두 선택 체크 스타일 위젯 (AllSelectChip) - 유지
// ------------------------------------------------------------------

class AllSelectChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const AllSelectChip({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.label = '모두 선택',
  });

  static const String _checkedIconPath = 'assets/icons/check_filled.svg';
  static const String _uncheckedIconPath = 'assets/icons/check_outlined.svg';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? _checkedIconPath : _uncheckedIconPath,
              width: 20,
              height: 20,
              // colorFilter는 SVG 파일이 currentColor를 지원하지 않을 때 사용
              colorFilter: isSelected 
                  ? ColorFilter.mode(AppColors.primary0, BlendMode.srcIn)
                  : ColorFilter.mode(AppColors.grayscale60, BlendMode.srcIn),
            ),
            
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body14R.copyWith(
                color: isSelected ? AppColors.primary0 : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}