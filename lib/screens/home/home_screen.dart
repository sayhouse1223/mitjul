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
      // TODO: 3단계에서 등록 화면(PostCreateScreen)으로 이동하는 로직을 추가해야 합니다.
      debugPrint("게시물 등록 버튼 클릭됨!");
      return; 
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // 탭별로 다른 AppBar를 보여주기 위한 함수
  PreferredSizeWidget _buildAppBar(int index) {
    // 탭 인덱스가 2(등록)보다 크면 실제 화면 인덱스는 -1이 됩니다.
    // FeedTab, SearchTab, PopularTab, MyPageTab의 실제 인덱스는 0, 1, 3, 4 입니다.
    final actualIndex = index > 2 ? index - 1 : index;

    // AppBar는 홈(피드) 화면(index 0)에만 로고와 알림 버튼을 표시합니다.
    if (_selectedIndex == 0) {
      return AppBar(
        title: SvgPicture.asset(
          'assets/logos/logo_mitjul.svg', // 로고 SVG 파일 경로 (추후 assets에 추가 필요)
          height: 24,
        ),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: 알림 화면으로 이동
              debugPrint("알림 버튼 클릭");
            },
          ),
          const SizedBox(width: 8),
        ],
      );
    } 
    
    // 나머지 탭들은 기본 AppBar를 사용하거나 각 탭 파일 내부에서 AppBar를 정의합니다.
    // 여기서는 기본 AppBar로 Placeholder를 제공합니다.
    return AppBar(
      title: Text(
        switch(_selectedIndex) {
          1 => '검색',
          3 => '인기 피드',
          4 => '마이 페이지',
          _ => '', // 2 (등록)는 버튼이므로 제외
        },
        style: AppTextStyles.header.copyWith(fontSize: 18),
      ),
    );
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