import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/features/search/widgets/book_search_result_item.dart';
import 'package:mitjul_app_new/models/book.dart';

class BookSearchResultList extends StatelessWidget {
  const BookSearchResultList({
    super.key,
    required this.books,
    this.onBookTap,
  });

  final List<Book> books;
  final ValueChanged<Book>? onBookTap;

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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

