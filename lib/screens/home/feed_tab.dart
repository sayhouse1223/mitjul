import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/services/local_post_storage.dart';
import 'package:mitjul_app_new/models/post.dart';

/// 피드 화면 위젯: 상단 로고/아이콘과 피드 목록이 함께 스크롤됩니다.
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// 로컬 저장소에서 포스트 로드
  void _loadPosts() {
    setState(() {
      _posts = LocalPostStorage().getAllPosts();
    });
    print('📋 [피드] ${_posts.length}개 포스트 로드됨');
  }

  // 포스트 피드 아이템
  Widget _buildPostItem(Post post) {
    final localImagePath = LocalPostStorage().getLocalImagePath(post.postId);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary0,
                    child: Text(
                      post.author.nickname[0],
                      style: AppTextStyles.body16B.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.nickname,
                          style: AppTextStyles.body16B,
                        ),
                        Text(
                          _formatDateTime(post.createdAt),
                          style: AppTextStyles.body14R.copyWith(
                            color: AppColors.grayscale50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 카드 이미지
            if (localImagePath != null)
              AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(localImagePath),
                  fit: BoxFit.cover,
                ),
              )
            else if (post.imageUrl != null)
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grayscale10,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 50, color: AppColors.grayscale30),
                    );
                  },
                ),
              ),

            // 인용구
            if (post.quote != null && post.quote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '"${post.quote}"',
                  style: AppTextStyles.body16M.copyWith(
                    color: AppColors.grayscale80,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // 감상평
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                post.content,
                style: AppTextStyles.body14R.copyWith(
                  color: AppColors.grayscale70,
                ),
              ),
            ),

            // 책 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grayscale50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.book, size: 16, color: AppColors.primary0),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.sourceTitle,
                            style: AppTextStyles.body14B,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            post.sourceAuthor,
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
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 포맷팅
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.year}.${dateTime.month}.${dateTime.day}';
    }
  }

  // 임시 피드 아이템 (포스트가 없을 때)
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: AppColors.grayscale30,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 작성된 포스트가 없습니다',
              style: AppTextStyles.body16M.copyWith(
                color: AppColors.grayscale50,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 첫 포스트를 작성해보세요',
              style: AppTextStyles.body14R.copyWith(
                color: AppColors.grayscale40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Header와 피드 목록을 순서대로 배치하여 함께 스크롤되게 합니다.
    return SafeArea(
      // SafeArea를 사용하여 상단 노치 영역 아래에 콘텐츠가 시작되도록 합니다.
      bottom: false, // 하단은 BottomNaviBar가 차지하므로 제외
      child: RefreshIndicator(
        onRefresh: () async {
          _loadPosts();
        },
        child: ListView.builder(
          // 상단 Header가 이미 패딩을 가지고 있으므로, ListView의 기본 패딩은 최소화합니다.
          padding: EdgeInsets.zero,
          itemCount: _posts.isEmpty ? 2 : _posts.length + 1, // Header + 포스트들
          itemBuilder: (context, index) {
            if (index == 0) {
              // 리스트의 첫 번째 항목으로 공통 Header 위젯을 반환합니다.
              return const AppHeader();
            }
            
            // 포스트가 없으면 빈 상태 표시
            if (_posts.isEmpty) {
              return _buildEmptyState();
            }
            
            // 포스트 아이템 표시
            return _buildPostItem(_posts[index - 1]);
          },
        ),
      ),
    );
  }
}