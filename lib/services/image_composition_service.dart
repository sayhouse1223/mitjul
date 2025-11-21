import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// 카드 이미지 합성 서비스
/// 
/// 배경 + 스티커 + 텍스트 + 책 정보를 하나의 이미지로 합성합니다.
class ImageCompositionService {
  /// GlobalKey를 사용하여 위젯을 이미지로 캡처
  static Future<File?> captureWidgetAsImage({
    required GlobalKey widgetKey,
    double pixelRatio = 3.0, // 고해상도를 위해 3.0 사용
  }) async {
    try {
      // RenderRepaintBoundary 가져오기
      RenderRepaintBoundary? boundary =
          widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('RenderRepaintBoundary를 찾을 수 없습니다.');
        return null;
      }

      // 이미지로 변환
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      // ByteData로 변환
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('ByteData 변환 실패');
        return null;
      }

      // 파일로 저장
      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/card_$timestamp.png');
      await file.writeAsBytes(buffer);

      return file;
    } catch (e) {
      debugPrint('이미지 캡처 오류: $e');
      return null;
    }
  }

  /// 이미지에 블러 효과 적용
  static Future<img.Image?> applyBlur(img.Image image, {int radius = 30}) async {
    try {
      // Gaussian Blur 적용
      final blurred = img.gaussianBlur(image, radius: radius);
      return blurred;
    } catch (e) {
      debugPrint('블러 적용 오류: $e');
      return null;
    }
  }

  /// 이미지에 화이트 오버레이 적용
  static img.Image applyWhiteOverlay(img.Image image, {int opacity = 180}) {
    // opacity: 0-255 (0: 투명, 255: 불투명)
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // 화이트 오버레이 적용 (알파 블렌딩)
        final blended = _blendWithWhite(pixel, opacity);
        image.setPixel(x, y, blended);
      }
    }
    return image;
  }

  /// 색상과 화이트를 블렌드
  static img.Color _blendWithWhite(img.Color original, int whiteOpacity) {
    // 알파 블렌딩 공식: result = (fg * alpha) + (bg * (1 - alpha))
    final alpha = whiteOpacity / 255.0;
    final r = (255 * alpha + original.r * (1 - alpha)).round();
    final g = (255 * alpha + original.g * (1 - alpha)).round();
    final b = (255 * alpha + original.b * (1 - alpha)).round();
    
    return img.ColorRgb8(r, g, b);
  }

  /// 네트워크 이미지를 다운로드하여 img.Image로 변환
  static Future<img.Image?> loadNetworkImage(String url) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      // 바이트 수집
      final List<int> bytes = [];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }
      
      final image = img.decodeImage(Uint8List.fromList(bytes));
      return image;
    } catch (e) {
      debugPrint('네트워크 이미지 로드 오류: $e');
      return null;
    }
  }

  /// img.Image를 File로 저장
  static Future<File?> saveImageToFile(img.Image image, String filename) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(img.encodePng(image));
      return file;
    } catch (e) {
      debugPrint('이미지 저장 오류: $e');
      return null;
    }
  }
}

