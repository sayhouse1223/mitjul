import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';

class AppTextStyles {
  // Header

  static const TextStyle header24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.5,
    height: 32 / 24, // lineHeight / fontSize
    color: AppColors.grayscale100,
  );

  static const TextStyle header = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.5,
    height: 28 / 20, // lineHeight / fontSize
    color: AppColors.grayscale100,
  );
  
  // Body
  static const TextStyle body18R = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.5,
    height: 26 / 18,
    color: AppColors.grayscale100,
  );
  
  
  static const TextStyle body16B = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: AppColors.grayscale100,
  );

  static const TextStyle body16M = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.grayscale100,
  );
  
  static const TextStyle body16R = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 24 / 16,
    color: AppColors.grayscale100,
  );
  
  static const TextStyle body15M = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 23 / 15,
    color: AppColors.grayscale100,
  );
  
  static const TextStyle body15R = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 23 / 15,
    color: AppColors.grayscale100,
  );
  static const TextStyle body14B = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 22 / 14,
    color: AppColors.grayscale100,
  );

  static const TextStyle body14M = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 22 / 14,
    color: AppColors.grayscale100,
  );
  
  static const TextStyle body14R = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 22 / 14,
    color: AppColors.grayscale100,
  );
  
  // Caption
  static const TextStyle caption12M = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 20 / 12,
    color: AppColors.grayscale100,
  );

  static const TextStyle caption12R = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 20 / 12,
    color: AppColors.grayscale100,
  );

  // 10px Regular (아주 작은 텍스트)
  static const TextStyle caption10R = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
