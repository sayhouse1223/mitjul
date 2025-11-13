import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';

/// 캐릭터 색상 유틸리티
class CharacterColors {
  // 색상 팔레트 (5가지)
  static const List<Color> colors = [
    AppColors.primary10, //dark blue
    AppColors.primary0, //blue
    AppColors.secondary0, //green
    AppColors.point1Error, //red
    AppColors.point2, //yellow
  ];
  
  // 배경 색상 (연한 버전)
  static const List<Color> backgroundColors = [
    AppColors.primaryMinus30, //blue
    AppColors.primaryMinus30, //blue
    AppColors.secondaryMinus30, //green
    AppColors.point1bg, //red
    AppColors.point2bg, //yellow
  ];
  
  /// 색상 인덱스로 메인 색상 가져오기
  static Color getColor(int index) {
    if (index < 0 || index >= colors.length) return colors[0];
    return colors[index];
  }
  
  /// 색상 인덱스로 배경 색상 가져오기
  static Color getBackgroundColor(int index) {
    if (index < 0 || index >= backgroundColors.length) return backgroundColors[0];
    return backgroundColors[index];
  }
}

/// 캐릭터 에셋 경로 유틸리티
class CharacterAssets {
  /// 캐릭터 몸 SVG 경로 (1-8)
  static String getBodyPath(int body) {
    if (body < 1 || body > 8) body = 1;
    return 'assets/images/character_body_$body.svg';
  }
  
  /// 캐릭터 눈 SVG 경로 (1-4)
  static String getEyePath(int eye) {
    if (eye < 1 || eye > 4) eye = 1;
    return 'assets/images/character_eye_$eye.svg';
  }
}