import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/screens/post/book_search_screen.dart';

/// Step 2: OCR 변환 (텍스트 추출)
/// 
/// 선택된 이미지에서 Google ML Kit을 사용하여 텍스트를 추출합니다.
/// 추출된 텍스트는 편집 가능하며, 추가 페이지를 촬영하여 텍스트를 이어붙일 수 있습니다.
class OcrExtractionScreen extends StatefulWidget {
  final File imageFile;
  final String? existingText; // 추가 페이지 촬영 시 기존 텍스트를 받음

  const OcrExtractionScreen({
    super.key,
    required this.imageFile,
    this.existingText,
  });

  @override
  State<OcrExtractionScreen> createState() => _OcrExtractionScreenState();
}

class _OcrExtractionScreenState extends State<OcrExtractionScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _extractText();
  }

  /// Google ML Kit을 사용한 텍스트 추출
  Future<void> _extractText() async {
    setState(() {
      _isProcessing = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // 기존 텍스트가 있으면 추가 모드
      String extractedText = '';
      if (widget.existingText != null && widget.existingText!.isNotEmpty) {
        extractedText = widget.existingText! + '\n';
      }

      // Google ML Kit Text Recognition (최신 API)
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
      final inputImage = InputImage.fromFile(widget.imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);

      print('📝 OCR 결과: ${recognizedText.text}');

      if (recognizedText.text.isEmpty) {
        setState(() {
          _isProcessing = false;
          _hasError = true;
          _errorMessage = '이미지에서 텍스트를 찾을 수 없습니다.\n직접 입력해주세요.';
          _textController.text = extractedText;
        });
      } else {
        extractedText += recognizedText.text;
        setState(() {
          _isProcessing = false;
          _textController.text = extractedText;
        });
      }

      // 리소스 정리
      textRecognizer.close();
    } catch (e) {
      print('❌ OCR 오류: $e');
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = 'OCR 처리 중 오류가 발생했습니다.\n직접 입력해주세요.';
        _textController.text = widget.existingText ?? '';
      });
    }
  }

  /// 다음 페이지 추가 기능 (일단 비활성화 - 나중에 추가 가능)
  void _addNextPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('추가 페이지 기능은 곧 추가될 예정입니다.')),
    );
  }

  /// 다음 단계로 이동 (Step 3: 책 검색)
  void _goToNextStep() {
    print('=== 다음 버튼 클릭됨 ===');
    final text = _textController.text.trim();
    print('입력된 텍스트 길이: ${text.length}');
    print('입력된 텍스트 내용: "$text"');

    // 텍스트 유효성 검사
    if (text.isEmpty) {
      print('❌ 텍스트가 비어있음');
      _showValidationDialog('추출된 텍스트가 비어있습니다.\n텍스트를 입력해주세요.');
      return;
    }

    if (text.length < 5) {
      print('❌ 텍스트가 너무 짧음 (${text.length}자)');
      _showValidationDialog('텍스트가 너무 짧습니다.\n최소 5자 이상 입력해주세요.');
      return;
    }

    print('✅ 책 검색 화면으로 이동 시도');
    // Step 3으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookSearchScreen(
          extractedText: text,
        ),
      ),
    ).then((_) {
      print('✅ 책 검색 화면 이동 완료');
    }).catchError((error) {
      print('❌ 화면 이동 오류: $error');
    });
  }

  /// 유효성 검사 다이얼로그
  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('안내'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 다음 버튼 활성화 조건: 텍스트가 비어있지 않고 처리 중이 아닐 때
    final isNextEnabled = !_isProcessing && _textController.text.trim().isNotEmpty;
    print('다음 버튼 활성화 상태: $isNextEnabled, 텍스트: "${_textController.text}"');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader.sub(
        title: '텍스트 변환',
        onBack: () => Navigator.of(context).pop(),
        rightButtonText: '다음',
        onRightAction: () {
          print('AppHeader에서 onRightAction 호출됨');
          _goToNextStep();
        },
        isRightButtonEnabled: isNextEnabled,
      ),
      body: _isProcessing
          ? _buildLoadingView()
          : _buildContentView(),
    );
  }

  /// 로딩 화면
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            '텍스트를 추출하고 있습니다...',
            style: AppTextStyles.body16M.copyWith(
              color: AppColors.grayscale60,
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 컨텐츠 화면
  Widget _buildContentView() {
    return Column(
      children: [
        // 선택된 이미지 미리보기
        Container(
          width: double.infinity,
          height: 200,
          color: AppColors.grayscale10,
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
          ),
        ),

        // 에러 메시지 (있을 경우)
        if (_hasError && _errorMessage != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.body14R.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 추출된 텍스트 편집 영역
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추출된 텍스트',
                  style: AppTextStyles.body16M.copyWith(
                    color: AppColors.grayscale80,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '텍스트를 직접 수정할 수 있습니다.',
                  style: AppTextStyles.caption12R.copyWith(
                    color: AppColors.grayscale60,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTextStyles.body16R,
                    decoration: InputDecoration(
                      hintText: '추출된 텍스트가 여기에 표시됩니다...',
                      hintStyle: AppTextStyles.body16R.copyWith(
                        color: AppColors.grayscale40,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grayscale20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary0, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      setState(() {}); // 다음 버튼 활성화 상태 업데이트
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 하단 버튼 영역
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton.icon(
            onPressed: _addNextPage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('다음 페이지 추가'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary0,
              side: BorderSide(color: AppColors.primary0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}

