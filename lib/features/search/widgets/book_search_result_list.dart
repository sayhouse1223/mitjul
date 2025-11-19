import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/features/search/widgets/book_search_result_item.dart';
import 'package:mitjul_app_new/models/book.dart';

class BookSearchResultList extends StatelessWidget {
  const BookSearchResultList({
    super.key,
    required this.books,
    this.onBookTap,
    this.scrollController,
  });

  final List<Book> books;
  final ValueChanged<Book>? onBookTap;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(color: AppColors.grayscale50),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: books.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.grayscale20,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookSearchResultItem(
          book: book,
          onTap: onBookTap,
        );
      },
    );
  }
}

