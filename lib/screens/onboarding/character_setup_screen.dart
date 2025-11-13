// lib/screens/onboarding/character_setup_screen.dart (수정)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/providers/onboarding_provider.dart';
import 'package:mitjul_app_new/utils/character_utils.dart';
import 'package:mitjul_app_new/components/index.dart'; // ⭐️ AppChip, AppButton 사용을 위해 추가 ⭐️

// 탭의 인덱스 매칭을 위한 Enum
enum CharacterTab { body, eye, color }

/// Step 2: 캐릭터 설정 화면 (모양/눈/색상 탭)
class CharacterSetupScreen extends StatefulWidget {
  const CharacterSetupScreen({super.key});

  @override
  State<CharacterSetupScreen> createState() => _CharacterSetupScreenState();
}

class _CharacterSetupScreenState extends State<CharacterSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 개수에 맞게 컨트롤러 초기화
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // 타이틀
            Text(
              '아바타를 만들어주세요',
              style: AppTextStyles.header.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 캐릭터 미리보기 (기존 로직 유지)
            Consumer<OnboardingProvider>(
              builder: (context, provider, child) {
                // ... (캐릭터 미리보기 위젯 로직) ...
                // 코드 길이 상, 캐릭터 미리보기 위젯 로직은 기존 코드를 그대로 사용한다고 가정합니다.
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CharacterColors.getBackgroundColor(provider.characterColor),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.8,
                          child: SvgPicture.asset(
                            CharacterAssets.getBodyPath(provider.characterBody),
                            width: 60,
                            height: 60,
                            colorFilter: ColorFilter.mode(
                              CharacterColors.getColor(provider.characterColor),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 1.8,
                          child: SvgPicture.asset(
                            CharacterAssets.getEyePath(provider.characterEye),
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // ⭐️ 탭 바 (AppChip으로 교체) ⭐️
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: CharacterTab.values.map((tab) {
                  final index = tab.index;
                  final isSelected = _tabController.index == index;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: AppChip(
                      label: switch(tab) {
                        CharacterTab.body => '모양',
                        CharacterTab.eye => '눈',
                        CharacterTab.color => '색상',
                      },
                      isSelected: isSelected,
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() {}); // 탭이 선택될 때 UI 갱신
                      },
                      style: ChipStyle.line, // 탭은 보통 Line 스타일 사용
                      size: ChipSize.small, // 작은 크기로 설정
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _BodySelectionTab(),
                  _EyeSelectionTab(),
                  _ColorSelectionTab(),
                ],
              ),
            ),
            
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // 이전 버튼 (Secondary, Large 사용)
                  Expanded(
                    child: AppButton(
                      label: '이전',
                      onPressed: () {
                        final provider = context.read<OnboardingProvider>();
                        provider.previousStep();
                      },
                      type: ButtonType.primaryLine, // Primary-Line 스타일 적용
                      isLarge: true,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 다음 버튼 (Primary-Fill, Large 사용)
                  Expanded(
                    child: Consumer<OnboardingProvider>(
                      builder: (context, provider, child) {
                        // 캐릭터 설정 단계는 선택 사항이 항상 유효하다고 가정하고 onPressed: () => provider.nextStep()
                        return AppButton(
                          label: '다음',
                          onPressed: () => provider.nextStep(),
                          type: ButtonType.primaryFill,
                          isLarge: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 몸 선택 탭 (기존 로직 유지)
class _BodySelectionTab extends StatelessWidget {
// ... (기존 BodySelectionTab 코드 유지)
  const _BodySelectionTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final bodyIndex = index + 1;
              final isSelected = provider.characterBody == bodyIndex;
              
              return GestureDetector(
                onTap: () => provider.setCharacterBody(bodyIndex),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grayscale10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary0 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          CharacterAssets.getBodyPath(bodyIndex),
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            AppColors.grayscale40,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary0,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// 캐릭터 눈 선택 탭 (기존 로직 유지)
class _EyeSelectionTab extends StatelessWidget {
// ... (기존 EyeSelectionTab 코드 유지)
  const _EyeSelectionTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final eyeIndex = index + 1;
              final isSelected = provider.characterEye == eyeIndex;
              
              return GestureDetector(
                onTap: () => provider.setCharacterEye(eyeIndex),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grayscale10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary0 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          CharacterAssets.getEyePath(eyeIndex),
                          width: 40,
                          height: 40,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary0,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// 캐릭터 색상 선택 탭 (기존 로직 유지)
class _ColorSelectionTab extends StatelessWidget {
// ... (기존 ColorSelectionTab 코드 유지)
  const _ColorSelectionTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = provider.characterColor == index;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => provider.setCharacterColor(index),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: CharacterColors.getColor(index),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}