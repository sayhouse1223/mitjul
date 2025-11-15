import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

// ------------------------------------------------------------------
// 버튼 타입 정의를 위한 Enum
// ------------------------------------------------------------------

// Primary: 메인 강조 (Fill/Line), Secondary: 보조 역할
enum ButtonType { primaryFill, primaryLine, secondary }
enum ButtonSize { large, small } // AppButton이 size를 사용한다면
// ------------------------------------------------------------------
// 1. 범용적인 AppButton 위젯 (Type/Size/Disabled)
// ------------------------------------------------------------------

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // null이면 비활성화 (Disabled)
  final ButtonType type;
  final bool isLarge; // Large/Small 사이즈 구분
  
  // ⭐️ [필수] 로딩 상태 매개변수 추가 (에러 해결 핵심) ⭐️
  final bool isLoading; 

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primaryFill, // 기본값: Primary Fill
    this.isLarge = true,                // 기본값: Large 사이즈
    this.isLoading = false,             // ⭐️ [필수] 기본값: false ⭐️
  });

  @override
  Widget build(BuildContext context) {
    // ⭐️ [수정] 비활성화 조건에 isLoading 추가 ⭐️
    final bool isDisabled = onPressed == null || isLoading;

    // 1. 사이즈별 높이, 폰트, Radius 결정
    final double height = isLarge ? 50.0 : 40.0;
    // Small 사이즈는 Secondary 스타일에서만 14R 사용 (Secondary는 Small만 존재)
    final TextStyle labelStyle = isLarge 
        ? AppTextStyles.body16M // Large: 16M
        : AppTextStyles.body14R; // Small: 14R (Secondary 스타일을 위함)
    final double borderRadius = 4.0;

    // 2. 타입 및 상태별 색상 결정
    Color activeBackgroundColor;
    Color disabledBackgroundColor; 
    Color activeForegroundColor;
    Color disabledForegroundColor; 
    Color borderColor;
    Color spinnerColor; // 로딩 스피너 색상

    switch (type) {
      case ButtonType.primaryFill:
        // 활성화/비활성화 시 색상을 미리 정의
        activeBackgroundColor = AppColors.primary0;
        disabledBackgroundColor = AppColors.primaryMinus30; 
        activeForegroundColor = Colors.white;
        disabledForegroundColor = AppColors.primaryMinus10; 

        if (isDisabled) {
          spinnerColor = AppColors.primaryMinus10;
        } else {
          spinnerColor = Colors.white;
        }
        borderColor = Colors.transparent;
        break;

      case ButtonType.primaryLine:
        activeBackgroundColor = Colors.white;
        disabledBackgroundColor = Colors.white; 

        activeForegroundColor = AppColors.primary0;
        disabledForegroundColor = AppColors.primaryMinus10; 

        if (isDisabled) {
          borderColor = AppColors.primaryMinus10;
          spinnerColor = AppColors.primaryMinus10;
        } else {
          borderColor = AppColors.primary10;
          spinnerColor = AppColors.primary0;
        }
        break;

      case ButtonType.secondary:
        // Secondary는 disabled가 없다고 가정하고 active 색상만 정의
        activeBackgroundColor = AppColors.primaryMinus30;
        disabledBackgroundColor = AppColors.primaryMinus30; 
        
        activeForegroundColor = AppColors.primary0; 
        disabledForegroundColor = AppColors.primary0; 
        
        borderColor = AppColors.primaryMinus30; 
        spinnerColor = AppColors.primary0; 
        break;
    }
    
    // 3. Size 제약조건 체크 (Secondary는 Small만 허용)
    if (type == ButtonType.secondary && isLarge) {
        debugPrint('Warning: Secondary button is typically used only for small size.');
    }
    
    // 4. 버튼 내용 (Label 또는 Spinner) 정의
    final Widget childContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
          )
        : Text(
            label,
            style: labelStyle.copyWith(
              // 폰트 색상도 isDisabled에 따라 분기 처리
              color: isDisabled ? disabledForegroundColor : activeForegroundColor,
            ),
          );
    
    // 5. 최종 위젯 반환
    return ElevatedButton(
      // 로딩 중이거나 onPressed가 null일 때만 null 전달하여 시스템 비활성화 스타일 적용
      onPressed: isDisabled ? null : onPressed, 
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, height),
        
        // 비활성화 상태 색상 명시
        backgroundColor: activeBackgroundColor,
        foregroundColor: activeForegroundColor,
        disabledBackgroundColor: disabledBackgroundColor, 
        disabledForegroundColor: disabledForegroundColor, 
        
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            // Line 타입의 테두리는 isDisabled 상태에 따라 borderColor를 사용해야 함
            color: (type == ButtonType.primaryLine || type == ButtonType.secondary) 
                ? borderColor 
                : Colors.transparent,
            width: (type == ButtonType.primaryLine || type == ButtonType.secondary) ? 1 : 0,
          ),
        ),
        padding: EdgeInsets.zero,
        // 비활성화 시 오버레이 효과 제거
        overlayColor: isDisabled ? Colors.transparent : null,
      ),
      // 자식 위젯으로 childContent 사용
      child: childContent,
    );
  }
}