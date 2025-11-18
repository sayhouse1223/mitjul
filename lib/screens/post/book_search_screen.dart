import 'package:flutter/material.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/services/google_books_api_service.dart'; // 서비스 임포트


// Book 모델을 다음 화면으로 전달할 수 있도록 final 변수로 받습니다.
class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GoogleBooksApiService _apiService = GoogleBooksApiService();
  List<Book> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 검색 로직
  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchBooks(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = "검색 결과가 없습니다.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "검색 중 오류가 발생했습니다: $e";
      });
    }
  }

  // 검색 결과 아이템 빌더
  Widget _buildBookItem(Book book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        // 썸네일 표시
        leading: (book.thumbnailUrl != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  book.thumbnailUrl!,
                  width: 50,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.book, size: 50, color: Colors.grey),
                ),
              )
            : const Icon(Icons.book_outlined, size: 50, color: Colors.grey),
        
        // 도서 정보
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              book.authors?.join(', ') ?? '저자 정보 없음',
              style: const TextStyle(fontSize: 14),
            ),
            if (book.publisher != null) 
              Text(book.publisher!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        
        // 책 선택 시 다음 단계로 이동
        onTap: () {
          // TODO: 3단계에서 이 책 정보를 '포스팅 작성' 화면으로 전달해야 합니다.
          // 현재는 간단한 알림창으로 대체합니다.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${book.title}을(를) 선택했습니다. 다음 단계로 이동합니다.')),
          );
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostCreationScreen(book: book))); 
        },
      ),
    );
  }

  // 상태 메시지 빌더 (로딩, 오류, 결과 없음)
  Widget _buildStatusWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          "검색 결과가 없습니다.\n다른 키워드로 검색해보세요.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return const SizedBox.shrink();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도서 검색', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // 1. 검색 입력 필드
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도서 제목, 저자 등을 입력하세요.',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onSubmitted: _performSearch, // 엔터를 누를 때 검색 실행
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // 2. 검색 결과 리스트 / 상태 위젯
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildBookItem(_searchResults[index]);
                    },
                  )
                : _buildStatusWidget(), // 로딩, 오류, 결과 없음 상태 표시
          ),
        ],
      ),
    );
  }
}