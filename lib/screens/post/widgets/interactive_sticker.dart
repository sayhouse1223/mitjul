import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/models/sticker.dart';
import 'package:mitjul_app_new/constants/colors.dart';

/// 크기 조절 및 회전이 가능한 인터랙티브 스티커 위젯
class InteractiveSticker extends StatelessWidget {
  final Sticker sticker;
  final bool isSelected;
  final Function(Sticker) onUpdate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const InteractiveSticker({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.onUpdate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final size = 80.0 * sticker.size;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 메인 스티커 (드래그로 이동)
        Positioned(
          left: sticker.position.dx,
          top: sticker.position.dy,
          child: GestureDetector(
            onTap: onTap,
            onPanUpdate: (details) {
              onUpdate(sticker.copyWith(
                position: Offset(
                  sticker.position.dx + details.delta.dx,
                  sticker.position.dy + details.delta.dy,
                ),
              ));
            },
            child: Transform.rotate(
              angle: sticker.rotation,
              child: Container(
                width: size,
                height: size,
                decoration: isSelected
                    ? BoxDecoration(
                        border: Border.all(color: AppColors.primary0, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: sticker.assetPath.endsWith('.svg')
                    ? SvgPicture.asset(sticker.assetPath, fit: BoxFit.contain)
                    : Image.asset(sticker.assetPath, fit: BoxFit.contain),
              ),
            ),
          ),
        ),

        // 선택 시에만 버튼 표시
        if (isSelected) ...[
          // 삭제 버튼 (좌상단)
          Positioned(
            left: sticker.position.dx +
                (0 * cos(sticker.rotation) - 0 * sin(sticker.rotation)) * sticker.size -
                16,
            top: sticker.position.dy +
                (0 * sin(sticker.rotation) + 0 * cos(sticker.rotation)) * sticker.size -
                16,
            child: GestureDetector(
              onTap: () {
                print('🗑️ 삭제');
                onDelete();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),

          // 크기 조절 & 회전 핸들 (우하단)
          Positioned(
            left: sticker.position.dx +
                (80 * cos(sticker.rotation) - 80 * sin(sticker.rotation)) * sticker.size -
                16,
            top: sticker.position.dy +
                (80 * sin(sticker.rotation) + 80 * cos(sticker.rotation)) * sticker.size -
                16,
            child: GestureDetector(
              onPanUpdate: (details) {
                // 스티커의 중심점 계산
                final centerX = sticker.position.dx +
                    (40 * cos(sticker.rotation) - 40 * sin(sticker.rotation)) * sticker.size;
                final centerY = sticker.position.dy +
                    (40 * sin(sticker.rotation) + 40 * cos(sticker.rotation)) * sticker.size;

                // 현재 핸들의 위치
                final handleX = sticker.position.dx +
                    (80 * cos(sticker.rotation) - 80 * sin(sticker.rotation)) * sticker.size;
                final handleY = sticker.position.dy +
                    (80 * sin(sticker.rotation) + 80 * cos(sticker.rotation)) * sticker.size;

                // 터치 위치 (화면 절대 좌표)
                final touchX = handleX + details.delta.dx;
                final touchY = handleY + details.delta.dy;

                // 중심에서 터치 위치까지의 벡터
                final dx = touchX - centerX;
                final dy = touchY - centerY;

                // 거리 -> 크기
                final distance = sqrt(dx * dx + dy * dy);
                final newSize = (distance / (40 * sqrt(2))).clamp(0.5, 3.0);

                // 각도 -> 회전
                final angle = atan2(dy, dx);
                final newRotation = angle - pi / 4; // 45도 보정 (우하단 핸들)

                onUpdate(sticker.copyWith(
                  size: newSize,
                  rotation: newRotation,
                ));
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary0,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Icon(Icons.refresh, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
