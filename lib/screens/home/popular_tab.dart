import 'package:flutter/material.dart';
import 'package:mitjul_app_new/components/app_header.dart';

/// 인기 피드 탭 화면
class PopularTab extends StatelessWidget {
  const PopularTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 공통 헤더 (로고 + 알림 아이콘)
          const AppHeader(),
          // 인기 피드 내용
          const Expanded(
            child: Center(
              child: Text('인기 피드 탭'),
            ),
          ),
        ],
      ),
    );
  }
}