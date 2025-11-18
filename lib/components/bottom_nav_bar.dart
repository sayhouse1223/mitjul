import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/models/user_profile.dart';
import 'package:mitjul_app_new/utils/character_utils.dart'; 

/// 하단 네비게이션 바 컴포넌트입니다.
class BottomNaviBar extends StatelessWidget {
  final int selectedIndex; // 현재 선택된 탭 인덱스
  final Function(int) onItemTapped; // 탭 클릭 시 호출될 콜백 함수

  const BottomNaviBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // 프로필 이미지 위젯 (마이페이지 탭 전용) - 캐릭터 표시
  Widget _buildProfileIcon(bool isSelected) {
    final user = FirebaseAuth.instance.currentUser;
    
    // 32x32 크기의 CircleAvatar를 Container로 감싸 테두리를 추가합니다.
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
                color: AppColors.primary0, // ON 상태: primary0 컬러 테두리
                width: 2.0,
              )
            : null, // OFF 상태: 테두리 없음
      ),
      child: ClipOval(
        child: user == null
            ? Container(
                color: AppColors.grayscale20,
                child: const Icon(Icons.person, color: AppColors.grayscale40, size: 20),
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Container(
                      color: AppColors.grayscale20,
                      child: const Icon(Icons.person, color: AppColors.grayscale40, size: 20),
                    );
                  }

                  final profileData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (profileData == null) {
                    return Container(
                      color: AppColors.grayscale20,
                      child: const Icon(Icons.person, color: AppColors.grayscale40, size: 20),
                    );
                  }

                  final profile = UserProfile.fromJson(profileData);
                  final bodyIndex = profile.characterBody;
                  final eyeIndex = profile.characterEye;
                  final colorIndex = profile.characterColor;

                  // 캐릭터가 설정되지 않은 경우
                  if (bodyIndex == -1 || eyeIndex == -1) {
                    return Container(
                      color: AppColors.grayscale20,
                      child: const Icon(Icons.person, color: AppColors.grayscale40, size: 20),
                    );
                  }

                  final containerColor = CharacterColors.getBackgroundColor(colorIndex);

                  // 캐릭터 렌더링
                  return Container(
                    color: containerColor,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 캐릭터 몸
                        if (bodyIndex != -1)
                          Transform.scale(
                            scale: 1.0, // 작은 크기로 조정
                            child: SvgPicture.asset(
                              CharacterAssets.getBodyPath(bodyIndex),
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                CharacterColors.getColor(colorIndex),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        // 캐릭터 눈
                        if (eyeIndex != -1)
                          Transform.scale(
                            scale: 1.0, // 작은 크기로 조정
                            child: SvgPicture.asset(
                              CharacterAssets.getEyePath(eyeIndex),
                              width: 24,
                              height: 24,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // 아이콘과 하단 점(dot)을 포함하는 위젯을 구성하는 헬퍼 함수
  Widget _buildNavIcon(String name, bool isSelected) {
    Widget iconWidget;

    if (name == 'my') {
      // 마이페이지는 프로필 아이콘 사용
      iconWidget = _buildProfileIcon(isSelected);
    } else {
      // 나머지 탭은 SVG 아이콘 사용
      final String iconPath = isSelected
          ? 'assets/icons/${name}_on.svg'
          : 'assets/icons/${name}_off.svg';
      
      iconWidget = SvgPicture.asset(
        iconPath,
        width: 32, // 아이콘 크기
        height: 32,
      );
    }

    // ON 상태일 때 아이콘 아래에 표시할 5px 원형 점 위젯
    final Widget dot = Container(
      width: 5.0,
      height: 5.0,
      decoration: const BoxDecoration(
        color: AppColors.primary0, // primary0 색상 사용
        shape: BoxShape.circle,
      ),
    );

    // 아이콘과 점을 세로로 정렬하고 간격을 조정합니다.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 4.0), // 아이콘과 점 사이의 4px 간격
        
        // 선택된 경우에만 점을 표시하고, 그렇지 않으면 5px 높이의 빈 공간을 유지하여
        // 모든 탭의 아이콘이 수직적으로 동일한 위치에 오도록 합니다 (CLS 방지).
        if (isSelected) 
          dot
        else
          const SizedBox(height: 5.0), // 5px 점 높이만큼 공간 확보
      ],
    );
  }

  // 네비게이션 아이템 정의
  List<BottomNavigationBarItem> _buildNavItems() {
    // 탭 순서: Home, Search, Write/Add, Popular, MyPage
    final List<String> iconNames = [
      'home', 
      'search',
      'add', 
      'popular',
      'my', // 마이페이지는 특별 처리
    ];

    return List.generate(iconNames.length, (index) {
      final String name = iconNames[index];
      final bool isSelected = index == selectedIndex;

      // _buildNavIcon 헬퍼 함수를 사용하여 아이콘 위젯과 점 로직을 포함시킵니다.
      return BottomNavigationBarItem(
        icon: _buildNavIcon(name, isSelected),
        label: name == 'add' ? '글쓰기' : '', 
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 네비게이션 바 상단에 구분선을 추가하기 위해 Container로 감싸줍니다.
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, 
        border: Border(
          top: BorderSide(
            color: AppColors.grayscale20, 
            width: 1.0, // 구분선 두께
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        backgroundColor: Colors.white, 
        selectedItemColor: AppColors.primary0, 
        unselectedItemColor: AppColors.grayscale40, 
        showSelectedLabels: false, 
        showUnselectedLabels: false,
        currentIndex: selectedIndex,
        onTap: onItemTapped, 
        items: _buildNavItems(),
        elevation: 0, // 기본 그림자 제거 (구분선이 대신하므로)
      ),
    );
  }
}