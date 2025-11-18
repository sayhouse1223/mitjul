import 'package:flutter/material.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/post_service.dart';

class PostCreationScreen extends StatefulWidget {
  final Book selectedBook;

  // 생성자에서 이전 화면에서 넘겨받은 Book 객체를 받습니다.
  const PostCreationScreen({required this.selectedBook, super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final PostService _postService = PostService();
  bool _isPosting = false;

  // 실제 포스팅 저장 로직 (Firestore 연결)
  Future<void> _submitPost() async {
    final quote = _quoteController.text.trim();
    final review = _reviewController.text.trim();

    if (quote.isEmpty && review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인용구나 감상 중 하나는 입력해야 합니다.')),
      );
      return;
    }
    
    setState(() {
      _isPosting = true;
    });

    try {
      // PostService를 사용하여 포스팅 생성 및 저장
      await _postService.createPost(
        quote: quote,
        review: review,
        book: widget.selectedBook,
      );
      
      // 저장 성공 시 피드 화면(Home) 등으로 이동
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포스팅이 성공적으로 저장되었습니다!'), backgroundColor: Colors.green),
        );
        // 포스팅 완료 후 화면 스택에서 포스팅 관련 화면을 모두 제거하고 홈으로 복귀
        // 이는 Home 화면이 가장 첫 번째 라우트(route.isFirst)라고 가정합니다.
        Navigator.of(context).popUntil((route) => route.isFirst); 
      }
      
    } catch (e) {
      if (mounted) {
        // 오류 메시지를 사용자에게 보여줍니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.selectedBook;

    return Scaffold(
      appBar: AppBar(
        title: const Text('포스팅 작성'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 선택된 책 정보 위젯
            _buildSelectedBookInfo(book),
            const SizedBox(height: 24),

            // 2. 인용구 입력 필드
            const Text(
              '발췌 인용구 (Quote)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quoteController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '책에서 마음에 드는 구절을 적어주세요.',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 24),

            // 3. 감상 입력 필드
            const Text(
              '나의 감상 (Review)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '이 책을 읽고 느낀 점을 자유롭게 기록해주세요.',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 30),

            // 4. 포스팅 제출 버튼
            ElevatedButton(
              onPressed: _isPosting ? null : _submitPost, // 포스팅 중에는 버튼 비활성화
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isPosting 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      '포스팅 저장하기',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBookInfo(Book book) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              book.thumbnailUrl ?? 'https://placehold.co/60x90/cccccc/333333?text=No+Image',
              width: 60,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // 책 제목 및 저자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '선택된 도서',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  book.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '저자: ${book.authors?.join(', ') ?? '정보 없음'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '출판사: ${book.publisher ?? '정보 없음'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}