import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; 

// 모델 및 유틸리티 임포트
import 'package:mitjul_app_new/models/post.dart';
import 'package:mitjul_app_new/utils/character_utils.dart';

// 분리된 스타일 시트 임포트 (사용자 구조 반영)
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';


/// 피드 목록에 사용되는 개별 피드 카드 위젯
class FeedCard extends StatelessWidget {
  final Post post;

  const FeedCard({super.key, required this.post});

  // 시간을 'n시간 전' 형태로 포맷하는 헬퍼 함수
  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}분 전';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}시간 전';
    } else {
      return DateFormat('yy.MM.dd').format(dateTime);
    }
  }
  
  // 아바타 위젯 분리 (SVG 에셋이 없을 경우 아이콘으로 임시 대체)
  Widget _buildAvatar(Post post) {
    final bodyIndex = post.characterBody;
    final eyeIndex = post.characterEye;
    final colorIndex = post.characterColor;
    
    final containerColor = CharacterColors.getBackgroundColor(colorIndex);
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: containerColor,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 캐릭터 몸 (SVG 에셋이 없으면 아이콘으로 임시 대체)
            if (bodyIndex != -1)
              Icon(
                Icons.star,
                size: 22,
                color: CharacterColors.getColor(colorIndex),
              ),
            // 캐릭터 눈 (SVG 에셋이 없으면 아이콘으로 임시 대체)
            if (eyeIndex != -1)
              const Icon(
                Icons.circle_outlined,
                size: 22,
                color: Colors.black,
              ),
            // 실제 SVG를 사용할 경우 (assets/svg/body_5.svg와 같은 경로 필요)
            // SvgPicture.asset(
            //   CharacterAssets.getBodyPath(bodyIndex),
            //   width: 20,
            //   height: 20,
            //   colorFilter: ColorFilter.mode(CharacterColors.getColor(colorIndex), BlendMode.srcIn),
            // ),
          ],
        ),
      ),
    );
  }

  // 닉네임 옆 팔로우 버튼 위젯
  Widget _buildFollowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: post.isFollowed ? AppColors.primaryMinus30 : AppColors.primary0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        post.isFollowed ? '팔로우 중' : '팔로우',
        style: AppTextStyles.caption12M.copyWith(
          color: post.isFollowed ? AppColors.primary0 : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 사용자 ID와 게시물 작성자 ID 비교 로직
    const String currentUserId = 'user_99999';
    final bool isMyPost = post.userId == currentUserId;
    
    // 피드 카드 레이아웃
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (아바타, 닉네임, 팔로우 버튼)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildAvatar(post),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.nickname,
                        style: AppTextStyles.body16M.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: AppTextStyles.caption12R.copyWith(color: AppColors.grayscale50),
                      ),
                    ],
                  ),
                ),
                if (!isMyPost)
                  _buildFollowButton(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. 인용구 영역
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grayscale10, 
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grayscale20, width: 1),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      post.quote,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body16M.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Text(
                    post.sourceTitle,
                    style: AppTextStyles.caption12R.copyWith(color: AppColors.grayscale50),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          
          // 3. 본문 (Original Text)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.originalText,
                  style: AppTextStyles.body14R,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '전체보기',
                  style: AppTextStyles.body14R.copyWith(color: AppColors.grayscale50),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // 4. 액션 버튼 (좋아요, 댓글 수)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: AppColors.grayscale40, size: 20),
                const SizedBox(width: 4),
                Text(
                  post.likes.toString(),
                  style: AppTextStyles.caption12M.copyWith(color: AppColors.grayscale40),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline, color: AppColors.grayscale40, size: 20),
                const SizedBox(width: 4),
                Text(
                  post.comments.toString(),
                  style: AppTextStyles.caption12M.copyWith(color: AppColors.grayscale40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}