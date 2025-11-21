import 'package:flutter/material.dart';

/// 카드 배경 타입
enum BackgroundType {
  gradient, // 책 표지 색상 추출 그라데이션
  blur,     // 책 표지 블러 + 화이트 오버레이
  custom,   // 프리셋 그라데이션
}

/// 텍스트 크기
enum TextSize {
  small,   // 14pt
  medium,  // 16pt
  large,   // 18pt
  xLarge,  // 20pt
}

/// 카드 스타일 설정
class CardStyle {
  // 배경 설정
  BackgroundType backgroundType;
  LinearGradient? customGradient; // custom 타입일 때 사용
  String? backgroundImageUrl; // blur 타입일 때 책 표지 URL

  // 텍스트 설정
  TextSize textSize;
  Color textColor;

  CardStyle({
    this.backgroundType = BackgroundType.gradient,
    this.customGradient,
    this.backgroundImageUrl,
    this.textSize = TextSize.medium,
    this.textColor = Colors.black,
  });

  /// 텍스트 크기를 double로 변환
  double getTextSizeValue() {
    switch (textSize) {
      case TextSize.small:
        return 14.0;
      case TextSize.medium:
        return 16.0;
      case TextSize.large:
        return 18.0;
      case TextSize.xLarge:
        return 20.0;
    }
  }

  CardStyle copyWith({
    BackgroundType? backgroundType,
    LinearGradient? customGradient,
    String? backgroundImageUrl,
    TextSize? textSize,
    Color? textColor,
  }) {
    return CardStyle(
      backgroundType: backgroundType ?? this.backgroundType,
      customGradient: customGradient ?? this.customGradient,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      textSize: textSize ?? this.textSize,
      textColor: textColor ?? this.textColor,
    );
  }
}

