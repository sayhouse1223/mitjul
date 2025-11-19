import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';
import 'package:mitjul_app_new/constants/colors.dart';

/// 피드 화면 위젯: 상단 로고/아이콘과 피드 목록이 함께 스크롤됩니다.
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  // 임시 피드 아이템
  Widget _buildFeedItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 250,
          alignment: Alignment.center,
          child: Text(
            '피드 아이템 $index',
            style: const TextStyle(fontSize: 18, color: AppColors.grayscale40),
          ),
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
      child: ListView.builder(
        // 상단 Header가 이미 패딩을 가지고 있으므로, ListView의 기본 패딩은 최소화합니다.
        padding: EdgeInsets.zero, 
        itemCount: 20 + 1, // Header + 20개의 피드 아이템
        itemBuilder: (context, index) {
          if (index == 0) {
            // 리스트의 첫 번째 항목으로 공통 Header 위젯을 반환합니다.
            return const AppHeader();
          }
          // 나머지 항목은 피드 아이템입니다.
          return _buildFeedItem(index - 1);
        },
      ),
    );
  }
}