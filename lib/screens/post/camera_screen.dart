import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/screens/post/ocr_extraction_screen.dart';

/// 카메라 촬영 화면
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 화면 진입 즉시 카메라 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  /// 카메라로 사진 촬영
  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // 촬영 완료 후 OCR 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OcrExtractionScreen(
              imageFile: File(image.path),
            ),
          ),
        );
      } else {
        // 취소한 경우 이전 화면으로
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라를 실행할 수 없습니다.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 카메라가 실행되는 동안 로딩 표시
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppHeader.sub(
        title: '카메라',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

