import 'package:flutter/material.dart';
// 모델 및 컴포넌트 임포트 (올바른 경로 사용)
import 'package:mitjul_app_new/models/post.dart';
import 'package:mitjul_app_new/components/feed_card.dart';

/// 홈 화면의 '피드' 탭에서 실제 게시물 목록을 보여주는 위젯입니다.
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  // Mock 데이터 리스트 생성 (실제로는 API 호출 또는 Firestore에서 가져와야 함)
  List<Post> _generateMockPosts() {
    // Post 모델에 정의된 Mock 생성자를 사용합니다.
    return List.generate(10, (index) => Post.mock('post_$index'));
  }

  @override
  Widget build(BuildContext context) {
    final mockPosts = _generateMockPosts();

    return ListView.builder(
      // Padding을 주면 AppBar 뒤로 스크롤되지 않습니다.
      padding: EdgeInsets.zero, 
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        // FeedCard 컴포넌트를 사용하여 목록에 노출
        return FeedCard(post: mockPosts[index]);
      },
    );
  }
}