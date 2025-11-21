import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/models/card_style.dart';
import 'package:mitjul_app_new/models/sticker.dart';
import 'package:mitjul_app_new/screens/post/card_editing_screen.dart';
import 'package:mitjul_app_new/services/color_extraction_service.dart';
import 'package:palette_generator/palette_generator.dart';

/// 카드 편집 패널 (하단 탭)
/// 
/// 배경, 텍스트, 스티커를 편집할 수 있는 탭 기반 UI
class EditingPanel extends StatelessWidget {
  final EditingTab selectedTab;
  final CardStyle cardStyle;
  final PaletteGenerator? bookPalette;
  final String? bookCoverUrl;
  final Function(EditingTab) onTabChange;
  final Function(BackgroundType, {LinearGradient? gradient}) onBackgroundTypeChange;
  final Function({TextSize? size, Color? color}) onTextStyleChange;
  final Function(String) onStickerAdd;

  const EditingPanel({
    super.key,
    required this.selectedTab,
    required this.cardStyle,
    required this.bookPalette,
    this.bookCoverUrl,
    required this.onTabChange,
    required this.onBackgroundTypeChange,
    required this.onTextStyleChange,
    required this.onStickerAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.grayscale20, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 탭 버튼들
          _buildTabBar(),

          // 선택된 탭의 컨텐츠
          Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            child: _buildTabContent(context),
          ),
        ],
      ),
    );
  }

  /// 탭 바
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton(
            label: '배경색',
            iconAsset: 'assets/icons/SelColor',
            tab: EditingTab.background,
          ),
          const SizedBox(width: 6),
          _buildTabButton(
            label: '텍스트',
            iconAsset: 'assets/icons/SelText',
            tab: EditingTab.text,
          ),
          const SizedBox(width: 6),
          _buildTabButton(
            label: '스티커',
            iconAsset: 'assets/icons/SelSticker',
            tab: EditingTab.sticker,
          ),
        ],
      ),
    );
  }

  /// 탭 버튼 (박스 스타일)
  Widget _buildTabButton({
    required String label,
    required String iconAsset,
    required EditingTab tab,
  }) {
    final isSelected = selectedTab == tab;
    return GestureDetector(
      onTap: () => onTabChange(tab),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.grayscale10 : AppColors.grayscale0,
          borderRadius: BorderRadius.circular(4),
          border: isSelected 
              ? Border.all(color: AppColors.grayscale30, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              isSelected ? '${iconAsset}_on.svg' : '${iconAsset}_off.svg',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption12R.copyWith(
                color: isSelected ? AppColors.grayscale90 : AppColors.grayscale50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 컨텐츠
  Widget _buildTabContent(BuildContext context) {
    switch (selectedTab) {
      case EditingTab.background:
        return _buildBackgroundTab();
      case EditingTab.text:
        return _buildTextTab(context);
      case EditingTab.sticker:
        return _buildStickerTab();
    }
  }

  /// 배경 탭
  Widget _buildBackgroundTab() {
    // 팔레트에서 추출한 12가지 그라데이션 (라이트 6개 + 다크 6개)
    final paletteGradients = ColorExtractionService.createGradientsFromPalette(bookPalette);
    final grayscaleGradient = ColorExtractionService.getGrayscaleGradient();
    final darkGrayscaleGradient = ColorExtractionService.getDarkGrayscaleGradient();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모든 배경 옵션을 한 줄에 표시 (Blur → Grayscale 2개 → 팔레트 12개)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 1. Blur 옵션 (맨 처음) - 실제 블러 효과 미리보기
              GestureDetector(
                onTap: () {
                  onBackgroundTypeChange(BackgroundType.blur);
                },
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.grayscale30,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: bookCoverUrl != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              bookCoverUrl!.replaceFirst('http://', 'https://'),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.grayscale20,
                                  child: Center(
                                    child: Text(
                                      'Blur',
                                      style: AppTextStyles.caption12R.copyWith(
                                        color: AppColors.grayscale60,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // 블러 + 화이트 오버레이
                            ClipRect(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 미리보기는 약한 블러
                                child: Container(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: AppColors.grayscale20,
                          child: Center(
                            child: Text(
                              'Blur',
                              style: AppTextStyles.body14M.copyWith(
                                color: AppColors.grayscale60,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              
              // 2. Grayscale Light
              GestureDetector(
                onTap: () {
                  onBackgroundTypeChange(BackgroundType.custom, gradient: grayscaleGradient);
                },
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: grayscaleGradient,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.grayscale30,
                      width: 1,
                    ),
                  ),
                ),
              ),
              
              // 3. Grayscale Dark
              GestureDetector(
                onTap: () {
                  onBackgroundTypeChange(BackgroundType.custom, gradient: darkGrayscaleGradient);
                },
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: darkGrayscaleGradient,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.grayscale30,
                      width: 1,
                    ),
                  ),
                ),
              ),
              
              // 4. 팔레트 추출 그라데이션들 (12개)
              ...paletteGradients.map((gradient) {
                return GestureDetector(
                  onTap: () {
                    onBackgroundTypeChange(BackgroundType.gradient, gradient: gradient);
                  },
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.grayscale30,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  /// 텍스트 탭
  Widget _buildTextTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('텍스트 크기', style: AppTextStyles.body14M),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTextSizeOption('Small', TextSize.small),
            const SizedBox(width: 8),
            _buildTextSizeOption('Medium', TextSize.medium),
            const SizedBox(width: 8),
            _buildTextSizeOption('Large', TextSize.large),
            const SizedBox(width: 8),
            _buildTextSizeOption('X-Large', TextSize.xLarge),
          ],
        ),
        const SizedBox(height: 16),
        Text('텍스트 색상', style: AppTextStyles.body14M),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: ColorExtractionService.getTextColorPalette().length,
            itemBuilder: (context, index) {
              final color = ColorExtractionService.getTextColorPalette()[index];
              return GestureDetector(
                onTap: () => onTextStyleChange(color: color),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cardStyle.textColor == color 
                          ? AppColors.primary0 
                          : AppColors.grayscale30,
                      width: cardStyle.textColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 텍스트 크기 옵션
  Widget _buildTextSizeOption(String label, TextSize size) {
    final isSelected = cardStyle.textSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTextStyleChange(size: size),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary0.withOpacity(0.1) : AppColors.grayscale10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary0 : AppColors.grayscale20,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption12R.copyWith(
              color: isSelected ? AppColors.primary0 : AppColors.grayscale70,
            ),
          ),
        ),
      ),
    );
  }

  /// 스티커 탭
  Widget _buildStickerTab() {
    final availableStickers = StickerPresets.getAvailableStickers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('스티커 선택', style: AppTextStyles.body14M),
        const SizedBox(height: 8),
        Text(
          '스티커를 길게 눌러 삭제할 수 있습니다',
          style: AppTextStyles.caption12R.copyWith(color: AppColors.grayscale60),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: availableStickers.length,
            itemBuilder: (context, index) {
              final stickerPath = availableStickers[index];
              return GestureDetector(
                onTap: () => onStickerAdd(stickerPath),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.grayscale10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.grayscale20,
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    stickerPath,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


