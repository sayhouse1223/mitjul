import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/buttons.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

enum SearchTabType { underline, book, liner }

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.tabType,
    this.onRegisterTap,
  });

  final SearchTabType tabType;
  final VoidCallback? onRegisterTap;

  String get _message {
    switch (tabType) {
      case SearchTabType.underline:
        return '라이너님께서 새로운 밑줄을 등록해보세요';
      case SearchTabType.book:
        return '찾고 싶은 책의 제목이나 저자를 검색해보세요.';
      case SearchTabType.liner:
        return '찾고 싶은 라이너를 검색해보세요.';
    }
  }

  String? get _buttonText {
    switch (tabType) {
      case SearchTabType.underline:
        return '밑줄 등록하기';
      case SearchTabType.book:
      case SearchTabType.liner:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top:72),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 검색 결과 없음 이미지
            Image.asset(
              'assets/images/none_result.png',
              width: 101,
              height: 93,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              '검색 결과가 없어요',
              style: AppTextStyles.body16M.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: AppTextStyles.body14R.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_buttonText != null && onRegisterTap != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: onRegisterTap,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    backgroundColor: AppColors.primaryMinus30,
                    foregroundColor: AppColors.primary0,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(
                        color: AppColors.primaryMinus30,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: Text(
                    _buttonText!,
                    style: AppTextStyles.body14R.copyWith(
                      color: AppColors.primary0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

