import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/// 공통 검색 입력 필드 위젯
///
/// - 검색어 입력, 제출, 초기화 등 반복되는 동작을 재사용할 수 있도록 구성합니다.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.hintText = '검색어 입력',
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.onSearchTap,
    this.backgroundColor = Colors.white,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.searchIconAsset = 'assets/icons/24_Search.svg',
    this.deleteIconAsset = 'assets/icons/24_delete.svg',
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearchTap;
  final Color backgroundColor;
  final EdgeInsetsGeometry contentPadding;
  final String searchIconAsset;
  final String deleteIconAsset;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late String _currentValue = widget.controller.text;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
      _currentValue = widget.controller.text;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final nextValue = widget.controller.text;
    if (_currentValue != nextValue) {
      setState(() {
        _currentValue = nextValue;
      });
      widget.onChanged?.call(nextValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grayscale20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayscale10.withOpacity(0.4),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.body15R.copyWith(
                  color: AppColors.grayscale40,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: widget.contentPadding,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              onPressed: _currentValue.isNotEmpty
                  ? () {
                      widget.controller.clear();
                      widget.onClear?.call();
                    }
                  : widget.onSearchTap ??
                      () => widget.onSubmitted?.call(widget.controller.text),
              icon: SvgPicture.asset(
                _currentValue.isNotEmpty ? widget.deleteIconAsset : widget.searchIconAsset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _currentValue.isNotEmpty ? AppColors.grayscale50 : theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

