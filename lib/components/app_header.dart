import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mitjul_app_new/constants/colors.dart';

/// 공통 앱 헤더 (로고 + 알림 아이콘)
/// 모든 탭에서 상단에 표시되는 공통 헤더 컴포넌트
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 상단 상태바 영역을 고려하여 패딩을 추가합니다.
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // 로고
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 30,
          ),
          // 알림 아이콘
          GestureDetector(
            onTap: () {
              // 알림 버튼 클릭 동작
              // TODO: 알림 화면으로 이동
              debugPrint('알림 버튼 클릭');
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
}

