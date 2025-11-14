import 'package:flutter/material.dart';

// 모델 및 유틸리티 임포트
import 'package:mitjul_app_new/models/post.dart';

// 분리된 스타일 시트 임포트 (사용자 구조 반영)
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

/**
 * 피드에 표시되는 단일 게시물 아이템 위젯입니다. 
 * (feed_card.dart와는 다른 간결한 카드 스타일입니다.)
 */
class FeedPostItem extends StatelessWidget {
  final Post post; 

  const FeedPostItem({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. 작성자 정보 ---
            Row(
              children: <Widget>[
                // 아바타 임시 표시
                CircleAvatar(
                  radius: 15,
                  backgroundColor: CharacterColors.getColor(post.characterColor),
                  child: const Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  post.nickname,
                  style: AppTextStyles.body14R.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${post.likes} 좋아요', 
                  style: AppTextStyles.caption12R.copyWith(color: AppColors.grayscale50),
                ),
              ],
            ),
            
            const Divider(height: 20, color: AppColors.grayscale20),

            // --- 2. 인용구 및 제목 ---
            Text(
              post.sourceTitle,
              style: AppTextStyles.caption12M.copyWith(color: AppColors.primary0),
            ),
            const SizedBox(height: 6),
            Text(
              post.quote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body16M,
            ),
            const SizedBox(height: 12),
            
            // --- 3. 감상평 미리보기 ---
            Text(
              post.originalText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body14R.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}