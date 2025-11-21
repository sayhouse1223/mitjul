import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// 책 표지 이미지에서 대표 색상을 추출하는 서비스
class ColorExtractionService {
  /// 색상을 매우 연하고 밝게 보정 (파스텔톤 - 라이트 모드)
  static Color _enhanceColorLight(Color color, {double saturationBoost = 0.15, double lightnessBoost = 0.2}) {
    final hslColor = HSLColor.fromColor(color);
    
    // 채도를 적당히 유지 (너무 진하지 않게)
    double newSaturation = hslColor.saturation;
    if (newSaturation < 0.25) {
      newSaturation = 0.25 + saturationBoost;
    } else {
      newSaturation = (newSaturation + saturationBoost).clamp(0.0, 0.7); // 최대 0.7로 제한
    }
    
    // 명도를 매우 높게 (모든 색상을 밝게)
    double newLightness = hslColor.lightness + lightnessBoost;
    if (newLightness < 0.5) {
      newLightness = 0.6; // 최소 0.6 (밝게)
    }
    newLightness = newLightness.clamp(0.6, 0.9); // 0.6 ~ 0.9 범위 (매우 밝음)
    
    return hslColor.withSaturation(newSaturation).withLightness(newLightness).toColor();
  }

  /// 색상을 매우 어둡게 보정 (다크 모드 - 더 진하게)
  static Color _enhanceColorDark(Color color, {double saturationBoost = 0.25, double lightnessAdjust = 0.0}) {
    final hslColor = HSLColor.fromColor(color);
    
    // 채도를 매우 높게 유지 (더 선명하고 진하게)
    double newSaturation = hslColor.saturation;
    if (newSaturation < 0.35) {
      newSaturation = 0.5 + saturationBoost;
    } else {
      newSaturation = (newSaturation + saturationBoost).clamp(0.0, 1.0); // 최대값까지
    }
    
    // 명도를 매우 낮게 (더 어둡게)
    double newLightness = hslColor.lightness + lightnessAdjust;
    if (newLightness > 0.35) {
      newLightness = 0.25; // 최대 0.25 (더 어둡게)
    }
    newLightness = newLightness.clamp(0.1, 0.35); // 0.1 ~ 0.35 범위 (매우 어두움)
    
    return hslColor.withSaturation(newSaturation).withLightness(newLightness).toColor();
  }
  /// 이미지에서 팔레트 색상 추출
  static Future<PaletteGenerator?> extractPalette(ImageProvider imageProvider) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );
      return paletteGenerator;
    } catch (e) {
      debugPrint('색상 추출 오류: $e');
      return null;
    }
  }

  /// 팔레트에서 그라데이션 생성 (12가지 프로필: 라이트 6개 + 다크 6개)
  static List<LinearGradient> createGradientsFromPalette(PaletteGenerator? palette) {
    if (palette == null) {
      return [
        _defaultGradient(),
        _defaultGradient(),
        _defaultGradient(),
        _defaultGradient(),
        _defaultGradient(),
        _defaultGradient(),
        _defaultDarkGradient(),
        _defaultDarkGradient(),
        _defaultDarkGradient(),
        _defaultDarkGradient(),
        _defaultDarkGradient(),
        _defaultDarkGradient(),
      ];
    }

    return [
      // 라이트 톤 6가지
      _createVibrantGradient(palette),
      _createDarkVibrantGradient(palette),
      _createLightVibrantGradient(palette),
      _createMutedGradient(palette),
      _createDarkMutedGradient(palette),
      _createLightMutedGradient(palette),
      // 다크 톤 6가지
      _createVibrantGradientDark(palette),
      _createDarkVibrantGradientDark(palette),
      _createLightVibrantGradientDark(palette),
      _createMutedGradientDark(palette),
      _createDarkMutedGradientDark(palette),
      _createLightMutedGradientDark(palette),
    ];
  }

  // ============ 라이트 톤 6가지 ============
  
  // Vibrant Light: 같은 색상 계열에서 명도 차이만 이용 (선명한 전환)
  static LinearGradient _createVibrantGradient(PaletteGenerator palette) {
    final vibrant = _enhanceColorLight(palette.vibrantColor?.color ?? Colors.grey);
    final lightVibrant = _enhanceColorLight(palette.lightVibrantColor?.color ?? vibrant, lightnessBoost: 0.25);
    final darkVibrant = _enhanceColorLight(palette.darkVibrantColor?.color ?? vibrant, lightnessBoost: 0.15);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightVibrant.withOpacity(0.4),
        vibrant.withOpacity(0.35),
        darkVibrant.withOpacity(0.45),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Dark Vibrant Light: 어두운 톤 + 차분한 색 조합 (깊이감)
  static LinearGradient _createDarkVibrantGradient(PaletteGenerator palette) {
    final darkVibrant = _enhanceColorLight(palette.darkVibrantColor?.color ?? Colors.grey.shade700);
    final vibrant = _enhanceColorLight(palette.vibrantColor?.color ?? darkVibrant);
    final darkMuted = _enhanceColorLight(palette.darkMutedColor?.color ?? darkVibrant);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkVibrant.withOpacity(0.45),
        darkMuted.withOpacity(0.35),
        vibrant.withOpacity(0.4),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  // Light Vibrant Light: 밝은 톤 조합 (드라마틱하고 깊이감)
  static LinearGradient _createLightVibrantGradient(PaletteGenerator palette) {
    final lightVibrant = _enhanceColorLight(palette.lightVibrantColor?.color ?? Colors.grey.shade300, lightnessBoost: 0.25);
    final vibrant = _enhanceColorLight(palette.vibrantColor?.color ?? lightVibrant);
    final darkMuted = _enhanceColorLight(palette.darkMutedColor?.color ?? lightVibrant);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightVibrant.withOpacity(0.35),
        vibrant.withOpacity(0.4),
        darkMuted.withOpacity(0.45),
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }

  // Muted Light: 차분한 색상 계열 (명도 차이만)
  static LinearGradient _createMutedGradient(PaletteGenerator palette) {
    final muted = _enhanceColorLight(palette.mutedColor?.color ?? Colors.grey.shade400);
    final lightMuted = _enhanceColorLight(palette.lightMutedColor?.color ?? muted, lightnessBoost: 0.25);
    final darkMuted = _enhanceColorLight(palette.darkMutedColor?.color ?? muted);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightMuted.withOpacity(0.35),
        muted.withOpacity(0.4),
        darkMuted.withOpacity(0.45),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Dark Muted Light: 어둡고 차분한 조합 (안정감)
  static LinearGradient _createDarkMutedGradient(PaletteGenerator palette) {
    final darkMuted = _enhanceColorLight(palette.darkMutedColor?.color ?? Colors.grey.shade600);
    final muted = _enhanceColorLight(palette.mutedColor?.color ?? darkMuted);
    final darkVibrant = _enhanceColorLight(palette.darkVibrantColor?.color ?? darkMuted);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkMuted.withOpacity(0.45),
        muted.withOpacity(0.35),
        darkVibrant.withOpacity(0.4),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  // Light Muted Light: 밝고 차분한 조합 (부드러움)
  static LinearGradient _createLightMutedGradient(PaletteGenerator palette) {
    final lightMuted = _enhanceColorLight(palette.lightMutedColor?.color ?? Colors.grey.shade200, lightnessBoost: 0.25);
    final muted = _enhanceColorLight(palette.mutedColor?.color ?? lightMuted);
    final lightVibrant = _enhanceColorLight(palette.lightVibrantColor?.color ?? lightMuted, lightnessBoost: 0.25);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightMuted.withOpacity(0.35),
        muted.withOpacity(0.4),
        lightVibrant.withOpacity(0.35),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ============ 다크 톤 6가지 ============
  
  // Vibrant Dark: 진하고 선명한 다크 그라데이션
  static LinearGradient _createVibrantGradientDark(PaletteGenerator palette) {
    final vibrant = _enhanceColorDark(palette.vibrantColor?.color ?? Colors.teal);
    final lightVibrant = _enhanceColorDark(palette.lightVibrantColor?.color ?? vibrant, lightnessAdjust: 0.05);
    final darkVibrant = _enhanceColorDark(palette.darkVibrantColor?.color ?? vibrant, lightnessAdjust: -0.05);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkVibrant.withOpacity(0.98),
        vibrant.withOpacity(0.95),
        lightVibrant.withOpacity(0.98),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Dark Vibrant Dark: 매우 어둡고 깊은 그라데이션
  static LinearGradient _createDarkVibrantGradientDark(PaletteGenerator palette) {
    final darkVibrant = _enhanceColorDark(palette.darkVibrantColor?.color ?? Colors.indigo.shade900, lightnessAdjust: -0.05);
    final vibrant = _enhanceColorDark(palette.vibrantColor?.color ?? darkVibrant);
    final darkMuted = _enhanceColorDark(palette.darkMutedColor?.color ?? darkVibrant, lightnessAdjust: -0.03);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkVibrant.withOpacity(1.0),
        darkMuted.withOpacity(0.95),
        vibrant.withOpacity(0.98),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  // Light Vibrant Dark: 상대적으로 밝은 다크 그라데이션
  static LinearGradient _createLightVibrantGradientDark(PaletteGenerator palette) {
    final lightVibrant = _enhanceColorDark(palette.lightVibrantColor?.color ?? Colors.cyan.shade800, lightnessAdjust: 0.05);
    final vibrant = _enhanceColorDark(palette.vibrantColor?.color ?? lightVibrant);
    final darkMuted = _enhanceColorDark(palette.darkMutedColor?.color ?? lightVibrant, lightnessAdjust: -0.05);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightVibrant.withOpacity(0.95),
        vibrant.withOpacity(0.98),
        darkMuted.withOpacity(1.0),
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }

  // Muted Dark: 차분하고 어두운 그라데이션
  static LinearGradient _createMutedGradientDark(PaletteGenerator palette) {
    final muted = _enhanceColorDark(palette.mutedColor?.color ?? Colors.blueGrey.shade800);
    final lightMuted = _enhanceColorDark(palette.lightMutedColor?.color ?? muted, lightnessAdjust: 0.05);
    final darkMuted = _enhanceColorDark(palette.darkMutedColor?.color ?? muted, lightnessAdjust: -0.05);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightMuted.withOpacity(0.95),
        muted.withOpacity(0.98),
        darkMuted.withOpacity(1.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Dark Muted Dark: 가장 어둡고 차분한 그라데이션
  static LinearGradient _createDarkMutedGradientDark(PaletteGenerator palette) {
    final darkMuted = _enhanceColorDark(palette.darkMutedColor?.color ?? Colors.grey.shade900, lightnessAdjust: -0.05);
    final muted = _enhanceColorDark(palette.mutedColor?.color ?? darkMuted);
    final darkVibrant = _enhanceColorDark(palette.darkVibrantColor?.color ?? darkMuted, lightnessAdjust: -0.03);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        darkMuted.withOpacity(1.0),
        muted.withOpacity(0.95),
        darkVibrant.withOpacity(0.98),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  // Light Muted Dark: 은은하게 어두운 그라데이션
  static LinearGradient _createLightMutedGradientDark(PaletteGenerator palette) {
    final lightMuted = _enhanceColorDark(palette.lightMutedColor?.color ?? Colors.blueGrey.shade700, lightnessAdjust: 0.05);
    final muted = _enhanceColorDark(palette.mutedColor?.color ?? lightMuted);
    final lightVibrant = _enhanceColorDark(palette.lightVibrantColor?.color ?? lightMuted, lightnessAdjust: 0.03);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lightMuted.withOpacity(0.95),
        muted.withOpacity(0.98),
        lightVibrant.withOpacity(0.95),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// 기본 그라데이션 (라이트)
  static LinearGradient _defaultGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade400,
        Colors.grey.shade500,
      ],
    );
  }

  /// 기본 그라데이션 (다크 - 더 진하게)
  static LinearGradient _defaultDarkGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade900.withOpacity(1.0),
        Colors.grey.shade800.withOpacity(0.98),
        Colors.grey.shade900.withOpacity(1.0),
      ],
    );
  }

  /// Grayscale 그라데이션 (라이트)
  static LinearGradient getGrayscaleGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEEEEEE), Color(0xFFF6F6F6), Color(0xFFDADADA)],
    );
  }

  /// Grayscale 그라데이션 (다크)
  static LinearGradient getDarkGrayscaleGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF111111), Color(0xFF222222), Color(0xFF000000)],
    );
  }

  /// 시스템 정의 색상 팔레트 (텍스트 색상용)
  static List<Color> getTextColorPalette() {
    return [
      Colors.black,
      Color(0xFF333333),
      Color(0xFF666666),
      Colors.white,
      Color(0xFFF5F5F5),
      Color(0xFF2196F3), // 파란색
      Color(0xFFE91E63), // 핑크
      Color(0xFF9C27B0), // 퍼플
      Color(0xFF4CAF50), // 그린
      Color(0xFFFF9800), // 오렌지
      Color(0xFFF44336), // 레드
      Color(0xFF00BCD4), // 시안
    ];
  }
}

