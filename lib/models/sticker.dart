import 'package:flutter/material.dart';

/// 스티커 모델
/// 
/// 카드에 배치되는 스티커의 위치, 크기, 회전 정보를 관리합니다.
class Sticker {
  final String id;
  final String assetPath; // 스티커 이미지 경로
  Offset position; // 캔버스 내 위치
  double size; // 스티커 크기 (기본 크기의 배율)
  double rotation; // 회전 각도 (라디안)

  Sticker({
    required this.id,
    required this.assetPath,
    required this.position,
    this.size = 1.0,
    this.rotation = 0.0,
  });

  Sticker copyWith({
    String? id,
    String? assetPath,
    Offset? position,
    double? size,
    double? rotation,
  }) {
    return Sticker(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// 프리셋 스티커 목록
class StickerPresets {
  static List<String> getAvailableStickers() {
    // assets/sticker/ 폴더의 스티커 이미지들 (Sticker01~29.png)
    return List.generate(
      29,
      (index) => 'assets/sticker/Sticker${(index + 1).toString().padLeft(2, '0')}.png',
    );
  }
}

