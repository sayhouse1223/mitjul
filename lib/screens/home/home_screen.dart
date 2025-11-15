import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// 파일 경로: lib/components/bottom_nav_bar.dart
import 'package:mitjul_app_new/components/bottom_nav_bar.dart'; 
import 'package:mitjul_app_new/constants/colors.dart';

// 임시 탭 화면들 (아직 구현되지 않았으므로 placeholder 사용)
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("검색 (Search)", style: TextStyle(fontSize: 24)));
}
class AddTab extends StatelessWidget {
  const AddTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("글쓰기 (Add)", style: TextStyle(fontSize: 24)));
}
class PopularTab extends StatelessWidget {
  const PopularTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("인기 (Popular)", style: TextStyle(fontSize: 24)));
}
class MyTab extends StatelessWidget {
  const MyTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("마이페이지 (My)", style: TextStyle(fontSize: 24)));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 초기 선택된 탭 인덱스 (홈)

  // 탭 화면 리스트
  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeFeedTab(), // 홈 피드는 별도 위젯으로 분리
    const SearchTab(),
    const AddTab(),
    const PopularTab(),
    const MyTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 AppBar를 제거하고, 하단 네비게이션 바만 유지합니다.
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // 하단 네비게이션 바는 여전히 고정됩니다.
      bottomNavigationBar: BottomNaviBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped, // 이제 정상적으로 호출됨
      ),
    );
  }
}


/// 피드 화면 위젯: 상단 로고/아이콘과 피드 목록이 함께 스크롤됩니다.
class _HomeFeedTab extends StatelessWidget {
  const _HomeFeedTab();

  // 상단 로고와 아이콘 영역 (스크롤 영역의 첫 번째 항목이 됨)
  Widget _buildHeader() {
    return Padding(
      // 상단 상태바 영역을 고려하여 패딩을 추가합니다.
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 로고 (assets/icons/logo.svg 가정)
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 30,
          ),
          // 알림 아이콘
          GestureDetector(
            onTap: () {
              // 알림 버튼 클릭 동작
              print('Alarm button tapped');
            },
            child: SvgPicture.asset(
              'assets/icons/alram_off.svg',
              width: 28,
              height: 28,
            ),
          ),
        ],
      ),
    );
  }

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
            // 리스트의 첫 번째 항목으로 Header 위젯을 반환합니다.
            return _buildHeader();
          }
          // 나머지 항목은 피드 아이템입니다.
          return _buildFeedItem(index - 1);
        },
      ),
    );
  }
}