import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/post_service.dart';

/// Step 5: 감상 입력 화면
/// 
/// 완성된 카드 이미지를 보여주고 감상평을 입력받습니다.
/// 화면 진입 시 자동으로 키보드가 올라오며,
/// 키보드 높이만큼 컨텐츠가 위로 스크롤됩니다.
class CaptionInputScreen extends StatefulWidget {
  final File cardImageFile;
  final Book selectedBook;
  final String extractedText;

  const CaptionInputScreen({
    super.key,
    required this.cardImageFile,
    required this.selectedBook,
    required this.extractedText,
  });

  @override
  State<CaptionInputScreen> createState() => _CaptionInputScreenState();
}

class _CaptionInputScreenState extends State<CaptionInputScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PostService _postService = PostService();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 즉시 텍스트 필드에 포커스 (키보드 자동 올림)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  /// 게시하기
  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();

    if (caption.isEmpty) {
      _showDialog('감상을 입력해주세요.');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // PostService를 사용하여 게시
      await _postService.createPostWithImage(
        cardImageFile: widget.cardImageFile,
        caption: caption,
        extractedText: widget.extractedText,
        book: widget.selectedBook,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시가 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );

        // 메인 피드로 이동 (모든 스택 제거)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _showDialog('게시 중 오류가 발생했습니다.\n$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  /// 다이얼로그 표시
  void _showDialog(String message) {
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
    _captionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 게시 버튼 활성화 조건
    final isPostEnabled = !_isPosting && _captionController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader.sub(
        title: '감상 입력',
        onBack: () => Navigator.of(context).pop(),
        rightButtonText: '게시',
        onRightAction: _submitPost,
        isRightButtonEnabled: isPostEnabled,
      ),
      body: GestureDetector(
        onTap: () {
          // 화면 탭 시 포커스 해제 방지 (키보드가 내려가지 않도록)
        },
        child: SingleChildScrollView(
          // 키보드가 올라올 때 자동으로 스크롤
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 완성된 카드 이미지
                Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                      maxHeight: 300,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        widget.cardImageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 안내 텍스트
              Text(
                '이 책을 읽고 느낀 점을 자유롭게 기록해주세요',
                style: AppTextStyles.body16M.copyWith(
                  color: AppColors.grayscale80,
                ),
              ),
                const SizedBox(height: 16),

                // 감상 입력 필드
                TextField(
                  controller: _captionController,
                  focusNode: _focusNode,
                  maxLines: 8,
                  maxLength: 500,
                  style: AppTextStyles.body16R,
                  decoration: InputDecoration(
                    hintText: '감상을 입력하세요...',
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
                    setState(() {}); // 게시 버튼 활성화 상태 업데이트
                  },
                ),
                const SizedBox(height: 16),

                // 로딩 인디케이터
                if (_isPosting)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

