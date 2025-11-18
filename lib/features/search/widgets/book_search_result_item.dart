import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/models/book.dart';

class BookSearchResultItem extends StatelessWidget {
  const BookSearchResultItem({
    super.key,
    required this.book,
    this.onTap,
  });

  final Book book;
  final ValueChanged<Book>? onTap;

  // 이미지 URL을 안전하게 변환
  String _getImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://placehold.co/70x100/E0E0E0/9E9E9E?text=No+Cover';
    }
    
    // http://를 https://로 변환
    String safeUrl = url.replaceFirst('http://', 'https://');
    
    // Google Books API의 이미지 URL은 직접 접근이 제한될 수 있음
    // 원본 URL을 그대로 사용하되, http만 https로 변환
    // 에러 발생 시 errorBuilder에서 placeholder를 표시함
    return safeUrl;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap != null ? () => onTap!(book) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayscale20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _getImageUrl(book.thumbnailUrl),
                width: 60,
                height: 88,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 60,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.grayscale10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Google Books 이미지 URL은 직접 접근이 제한될 수 있어
                  // 에러 발생 시 placeholder 표시
                  return Container(
                    width: 60,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.grayscale10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, color: AppColors.grayscale40, size: 30),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grayscale90,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.authors?.join(', ') ?? '저자 정보 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayscale50,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.publisher ?? '출판사 정보 없음',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grayscale40,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

