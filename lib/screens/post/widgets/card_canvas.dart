import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/models/card_style.dart';
import 'package:mitjul_app_new/models/sticker.dart';
import 'package:mitjul_app_new/screens/post/widgets/interactive_sticker.dart';

/// 1:1 비율의 카드 캔버스
/// 
/// Layer Hierarchy (Z-Index 순서):
/// 1. (Bottom) 배경 레이어
/// 2. (Middle) 스티커 레이어
/// 3. (Top) 텍스트 + 책 정보 레이어
class CardCanvas extends StatelessWidget {
  final CardStyle cardStyle;
  final List<Sticker> stickers;
  final String? selectedStickerId;
  final String extractedText;
  final Book book;
  final Function(Sticker) onStickerUpdate;
  final Function(String) onStickerSelect;
  final Function(String) onStickerDelete;

  const CardCanvas({
    super.key,
    required this.cardStyle,
    required this.stickers,
    this.selectedStickerId,
    required this.extractedText,
    required this.book,
    required this.onStickerUpdate,
    required this.onStickerSelect,
    required this.onStickerDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 스티커 핸들이 잘리지 않도록 오버플로우 허용
      children: [
        // ClipRect로 배경, 텍스트, 책 정보만 잘라냄
        Positioned.fill(
          child: ClipRect(
            child: Stack(
              children: [
                // Layer 1: 배경
                Positioned.fill(
                  child: _buildBackground(),
                ),

                // Layer 3: 텍스트 + 책 정보
                Positioned.fill(
                  child: _buildTextAndBookInfo(),
                ),
              ],
            ),
          ),
        ),

        // Layer 2: 스티커들 (ClipRect 밖에서 오버플로우 허용)
        ...stickers.map((sticker) => InteractiveSticker(
          sticker: sticker,
          isSelected: sticker.id == selectedStickerId,
          onUpdate: onStickerUpdate,
          onTap: () => onStickerSelect(sticker.id),
          onDelete: () => onStickerDelete(sticker.id),
        )),
      ],
    );
  }

  /// Layer 1: 배경 레이어
  Widget _buildBackground() {
    switch (cardStyle.backgroundType) {
      case BackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: cardStyle.customGradient ?? _defaultGradient(),
          ),
        );

      case BackgroundType.blur:
        if (cardStyle.backgroundImageUrl == null) {
          return Container(color: Colors.grey.shade200);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            // 블러 처리된 책 표지
            Image.network(
              cardStyle.backgroundImageUrl!.replaceFirst('http://', 'https://'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey.shade200);
              },
            ),
            // 블러 효과 (BackdropFilter 사용)
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40), // 블러 강도 감소 (30 → 15)
              child: Container(
                color: Colors.white.withOpacity(0.6), // 화이트 오버레이 감소 (0.7 → 0.5)
              ),
            ),
          ],
        );

      case BackgroundType.custom:
        return Container(
          decoration: BoxDecoration(
            gradient: cardStyle.customGradient ?? _defaultGradient(),
          ),
        );
    }
  }

  /// 기본 그라데이션
  LinearGradient _defaultGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFEEEEEE), Color(0xFFF6F6F6), Color(0xFFDADADA)],
    );
  }

  /// Layer 3: 텍스트 + 책 정보
  Widget _buildTextAndBookInfo() {
    return Column(
      children: [
        // 텍스트 영역 (책 정보를 제외한 나머지 공간)
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                extractedText,
                style: TextStyle(
                  fontSize: cardStyle.getTextSizeValue(),
                  color: cardStyle.textColor,
                  height: 1.6,
                  fontFamily: 'Suit',
                ),
                textAlign: TextAlign.center,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        // 책 정보 영역 (하단 고정)
        _buildBookInfo(),
      ],
    );
  }

  /// 책 정보 영역 (박스 스타일)
  Widget _buildBookInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // 책 표지 썸네일
            if (book.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(
                  book.thumbnailUrl!.replaceFirst('http://', 'https://'),
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 60,
                      color: AppColors.grayscale20,
                      child: const Icon(Icons.book, size: 24, color: AppColors.grayscale40),
                    );
                  },
                ),
              ),
            const SizedBox(width: 12),

            // 책 제목 및 저자
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.body14M.copyWith(
                      color: AppColors.grayscale90,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors?.join(', ') ?? '저자 정보 없음',
                    style: AppTextStyles.caption12R.copyWith(
                      color: AppColors.grayscale60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

