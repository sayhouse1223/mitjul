import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/// 선택 가능한 버튼 컴포넌트
/// 
/// 선택된 상태와 선택되지 않은 상태를 구분하여 표시하는 재사용 가능한 버튼
/// 텍스트 크기 선택, 스타일 옵션 등에서 사용
class SelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckIcon;

  const SelectionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showCheckIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary0 : AppColors.grayscale10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary0 : AppColors.grayscale30,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 체크 아이콘 (선택된 경우만 표시)
            if (isSelected && showCheckIcon) ...[
              SvgPicture.asset(
                'assets/icons/16_check.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            // 레이블
            Text(
              label,
              style: AppTextStyles.body14M.copyWith(
                color: isSelected ? Colors.white : AppColors.grayscale60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


