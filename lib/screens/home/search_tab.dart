import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/features/search/controllers/book_search_controller.dart';
import 'package:mitjul_app_new/features/search/widgets/book_search_result_list.dart';
import 'package:mitjul_app_new/features/search/widgets/search_bar.dart';
import 'package:mitjul_app_new/models/book.dart';
import 'package:mitjul_app_new/screens/post/post_creation_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchFieldController = TextEditingController();
  late final BookSearchController _bookSearchController = BookSearchController();

  @override
  void dispose() {
    _searchFieldController.dispose();
    _bookSearchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _bookSearchController.search(query);
  }

  void _handleBookSelection(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostCreationScreen(selectedBook: book),
      ),
    );
  }

  Widget _buildResults(SearchStatus status) {
    switch (status) {
      case SearchStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary0),
        );
      case SearchStatus.error:
        return _buildMessage(_bookSearchController.errorMessage ?? '검색 중 오류가 발생했습니다.');
      case SearchStatus.empty:
        return _buildMessage('검색 결과가 없습니다.\n다른 키워드로 검색해보세요.');
      case SearchStatus.success:
        return BookSearchResultList(
          books: _bookSearchController.books,
          onBookTap: _handleBookSelection,
        );
      case SearchStatus.idle:
      default:
        return _buildMessage('찾고 싶은 책의 제목이나 저자를 검색해보세요.');
    }
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.grayscale50,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🌟 검색 필드 디자인 적용
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppSearchBar(
            controller: _searchFieldController,
            hintText: '검색어 입력',
            onSubmitted: _handleSearch,
            onSearchTap: () => _handleSearch(_searchFieldController.text),
            onClear: _bookSearchController.clear,
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _bookSearchController,
            builder: (context, _) => _buildResults(_bookSearchController.status),
          ),
        ),
      ],
    );
  }
}