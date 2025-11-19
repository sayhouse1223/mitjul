import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
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
      onTap: onTap != null ? () => onTap!(book) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                _getImageUrl(book.thumbnailUrl),
                width: 80,
                height: 118,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 118,
                    color: AppColors.grayscale10,
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
                  return Container(
                    width: 80,
                    height: 118,
                    color: AppColors.grayscale10,
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
                  // 도서명
                  Text(
                    book.title,
                    style: AppTextStyles.body16M.copyWith(
                      color: AppColors.grayscale80,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 도서 부제목
                  if (book.subtitle != null && book.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.subtitle!,
                      style: AppTextStyles.body14R.copyWith(
                        color: AppColors.grayscale70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // 저자/역자
                  Text(
                    book.authors != null && book.authors!.isNotEmpty
                        ? book.authors!.join(' / ')
                        : '저자 정보 없음',
                    style: AppTextStyles.caption12R.copyWith(
                      color: AppColors.grayscale60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 출판사
                  Text(
                    book.publisher ?? '출판사 정보 없음',
                    style: AppTextStyles.caption12R.copyWith(
                      color: AppColors.grayscale60,
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

