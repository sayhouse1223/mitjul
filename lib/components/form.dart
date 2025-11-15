import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

// 오른쪽 끝에 노출되는 텍스트/버튼의 타입을 정의
enum InputSuffixType { 
  none, // 기본 스타일 (suffix 없음)
  systemText, // 오른쪽 끝에 시스템 텍스트 노출 (예: 0/12)
  button, // 오른쪽 끝에 버튼 노출 (예: 확인)
}

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final InputSuffixType suffixType;
  final String? suffixText; // suffixType이 systemText일 때 사용
  final String? prefixText; // 왼쪽 접두사 텍스트
  final VoidCallback? onSuffixPressed; // suffixType이 button일 때 사용
  final bool isRightAligned; // 텍스트 오른쪽 정렬 여부
  final bool enabled; // 비활성화 여부
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  
  const AppTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.suffixType = InputSuffixType.none,
    this.suffixText,
    this.prefixText, 
    this.onSuffixPressed,
    this.isRightAligned = false, // 기본값: 왼쪽 정렬
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 폰트사이즈 15R, 높이 50
    const double height = 50.0;
    const double borderRadius = 4.0;
    
    // 1. 상태별 색상 결정
    final bool isFocused = _focusNode.hasFocus;
    final bool isDisabled = !widget.enabled;

    Color fillColor;
    Color borderColor;
    Color textColor;

    if (isDisabled) {
      // Disabled 상태
      fillColor = AppColors.grayscale10;
      borderColor = AppColors.grayscale20; // 테두리 그레이 20 유지
      textColor = AppColors.grayscale40; // 텍스트컬러 그레이 40
    } else if (isFocused) {
      // Active (Focus) 상태
      fillColor = Colors.white;
      borderColor = AppColors.primary0; // 테두리 프라이머리 0
      textColor = AppColors.grayscale70; // 텍스트컬러 그레이 70
    } else {
      // Normal 상태
      fillColor = Colors.white; // 면색 화이트
      borderColor = AppColors.grayscale20; // 테두리 그레이 20
      textColor = AppColors.grayscale70; 
    }

    // 2. Suffix 위젯 구성
    Widget? buildSuffix() {
      switch (widget.suffixType) {
        case InputSuffixType.systemText:
          if (widget.suffixText == null) return null;
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              widget.suffixText!,
              style: AppTextStyles.body15R.copyWith(
                color: isDisabled ? AppColors.grayscale40 : AppColors.grayscale40,
              ),
            ),
          );
        
        case InputSuffixType.button:
          // AppTextField 내부에서만 쓰이는 버튼이므로 TextButton을 사용합니다.
          // 외부에서 정의된 AppButton을 가져와서 쓰지 않습니다.
          return TextButton(
            onPressed: isDisabled ? null : widget.onSuffixPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.suffixText ?? '버튼',
              style: AppTextStyles.body15R.copyWith(
                color: isDisabled ? AppColors.grayscale40 : AppColors.primary0,
              ),
            ),
          );
          
        case InputSuffixType.none:
        default:
          return null;
      }
    }
    
    // 3. Prefix 위젯 구성
    Widget? buildPrefix() {
      if (widget.prefixText == null) return null;
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text(
          widget.prefixText!,
          style: AppTextStyles.body15R.copyWith(
            color: isDisabled ? AppColors.grayscale40 : AppColors.grayscale40,
          ),
        ),
      );
    }


    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: isFocused ? 2.0 : 1.0,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        textAlign: widget.isRightAligned ? TextAlign.right : TextAlign.left,
        
        // 폰트 스타일: 15R
        style: AppTextStyles.body15R.copyWith(
          color: textColor,
        ),
        
        // 커서 색상
        cursorColor: AppColors.primary0,

        // 입력창 스타일
        decoration: InputDecoration(
          hintText: widget.hintText,
          // 플레이스홀더 텍스트 색상 그레이 40
          hintStyle: AppTextStyles.body15R.copyWith(
            color: AppColors.grayscale40,
          ),
          
          // TextField의 자체 border, counterText 등 모두 제거
          border: InputBorder.none,
          counterText: '', 
          
          // 좌우 여백 16px (Prefix/Suffix가 없는 경우)
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.prefixText != null ? 0 : 16.0,
            vertical: 0, // 높이 50에 맞춰 중앙 정렬되도록 0
          ),
          
          // Suffix 및 Prefix 위젯 연결
          suffixIcon: buildSuffix(),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: buildPrefix(),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
        
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}