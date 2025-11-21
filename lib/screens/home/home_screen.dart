import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/components/bottom_nav_bar.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';

// 앞으로 만들게 될 탭 화면들을 미리 임포트합니다.
import 'package:mitjul_app_new/screens/home/feed_tab.dart'; 
import 'package:mitjul_app_new/screens/home/search_tab.dart'; 
import 'package:mitjul_app_new/screens/home/popular_tab.dart'; 
import 'package:mitjul_app_new/screens/home/my_page_tab.dart';
import 'package:mitjul_app_new/screens/post/gallery_picker_screen.dart'; 

/// 메인 홈 화면 (Bottom Navigation Bar 포함)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 현재 선택된 탭의 인덱스
  int _selectedIndex = 0; 
  
  // 탭 목록: 홈(피드), 검색, 등록(중앙 버튼), 인기피드, 마이페이지
  static const List<Widget> _widgetOptions = <Widget>[
    FeedTab(),      // 0: 홈(피드)
    SearchTab(),    // 1: 검색
    // 2: 등록 버튼 (화면이 아닌 기능을 수행하므로 여기서 Placeholder로 둠)
    // 실제로는 버튼 클릭 시 모달이나 새 화면으로 이동
    Center(child: Text('등록 화면 Placeholder')), 
    PopularTab(),   // 3: 인기피드
    MyPageTab(),    // 4: 마이페이지
  ];

  void _onItemTapped(int index) {
    // ⭐️ [등록 버튼] 중앙 버튼(인덱스 2) 클릭 시 탭 전환 대신 등록 화면으로 이동 ⭐️
    if (index == 2) {
      // 게시물 작성 플로우 시작: Step 1 - 갤러리 선택 (인스타그램 스타일)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const GalleryPickerScreen(),
        ),
      );
      return; 
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // 탭별로 다른 AppBar를 보여주기 위한 함수
  PreferredSizeWidget? _buildAppBar(int index) {
    // 모든 탭에서 공통 헤더(AppHeader)를 사용하므로 AppBar 제거
    // 피드, 검색, 인기 피드 탭은 각각 내부에서 AppHeader를 처리
    // 마이 페이지 탭만 필요시 AppBar 사용 가능
    if (_selectedIndex == 4) {
      // 마이 페이지 탭은 필요시 AppBar 사용
      return AppBar(
        title: Text(
          '마이 페이지',
          style: AppTextStyles.header.copyWith(fontSize: 18),
        ),
      );
    }
    
    // 나머지 탭들은 공통 헤더를 사용하므로 AppBar 없음
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭에 따라 동적으로 AppBar를 변경
      appBar: _buildAppBar(_selectedIndex), 
      
      // 선택된 탭의 화면을 보여줍니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      
      // ⭐️ 하단 내비게이션 바 ⭐️
      bottomNavigationBar: BottomNaviBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}