// lib/components/buttons.dart (최종 수정)

import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

// ------------------------------------------------------------------
// 버튼 타입 정의를 위한 Enum
// ------------------------------------------------------------------

// Primary: 메인 강조 (Fill/Line), Secondary: 보조 역할
enum ButtonType { primaryFill, primaryLine, secondary }

// ------------------------------------------------------------------
// 1. 범용적인 AppButton 위젯 (Type/Size/Disabled)
// ------------------------------------------------------------------

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null이면 비활성화 (Disabled)
  final ButtonType type;
  final bool isLarge; // Large/Small 사이즈 구분

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primaryFill, // 기본값: Primary Fill
    this.isLarge = true,                // 기본값: Large 사이즈
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    // 1. 사이즈별 높이, 폰트, Radius 결정
    final double height = isLarge ? 56.0 : 40.0;
    // Small 사이즈는 Secondary 스타일에서만 14R 사용 (Secondary는 Small만 존재)
    final TextStyle labelStyle = isLarge 
        ? AppTextStyles.body16M // Large: 16M
        : AppTextStyles.body14R; // Small: 14R (Secondary 스타일을 위함)
    final double borderRadius = 4.0;

    // 2. 타입 및 상태별 색상 결정
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    switch (type) {
      case ButtonType.primaryFill:
        if (isDisabled) {
          // Disabled: 배경: Primary-30, 폰트: Primary-10
          backgroundColor = AppColors.primaryMinus30;
          foregroundColor = AppColors.primaryMinus10;
        } else {
          // Active: 배경: Primary, 폰트: White
          backgroundColor = AppColors.primary0;
          foregroundColor = Colors.white;
        }
        borderColor = Colors.transparent;
        break;

      case ButtonType.primaryLine:
        if (isDisabled) {
          // Disabled: 배경: White, 폰트/테두리: Primary-10
          backgroundColor = Colors.white;
          foregroundColor = AppColors.primaryMinus10;
          borderColor = AppColors.primaryMinus10;
        } else {
          // Active: 배경: White, 폰트/테두리: Primary
          backgroundColor = Colors.white;
          foregroundColor = AppColors.primary0;
          borderColor = AppColors.primary10;
        }
        break;

      case ButtonType.secondary:
        // Secondary는 small 사이즈만, disabled 상태 없음 (onPressed가 null일 수 없음)
        backgroundColor = Colors.white;
        foregroundColor = AppColors.primary0; // 예시로 primary 색상 사용
        borderColor = AppColors.grayscale30; // 예시로 회색 테두리 사용
        break;
    }

    // 3. Size 제약조건 체크 (Secondary는 Small만 허용)
    if (type == ButtonType.secondary && isLarge) {
        // 개발 오류 방지 (필요하다면 throw error 또는 경고 로직 추가)
        debugPrint('Warning: Secondary button is typically used only for small size.');
    }
    
    // 4. 최종 위젯 반환
    return ElevatedButton(
      onPressed: isDisabled && type != ButtonType.secondary ? null : onPressed, 
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, height),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor,
            width: (type == ButtonType.primaryLine || type == ButtonType.secondary) ? 1 : 0,
          ),
        ),
        padding: EdgeInsets.zero,
        // 비활성화 시 오버레이 효과 제거
        overlayColor: isDisabled ? Colors.transparent : null,
      ),
      child: Text(
        label,
        style: labelStyle.copyWith(
          color: foregroundColor,
        ),
      ),
    );
  }
}