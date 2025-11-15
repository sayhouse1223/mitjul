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
    
    // 탭 전환 시 상태 갱신을 위해 리스너 추가 (탭 바 색상 갱신용)
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // ⭐️ [NEW] 탭 전환 함수: 자식 위젯에 전달하여 사용 ⭐️
  void _switchToTab(CharacterTab tab) {
    _tabController.animateTo(tab.index);
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
                
                // 1. ⭐️ [수정] '절대 초기 상태'를 정의합니다. (모든 항목이 -1일 때만 true) ⭐️
                final isInitialState = provider.characterBody == -1 && 
                                       provider.characterEye == -1 && 
                                       provider.characterColor == -1;
                // 2. 렌더링에 사용할 인덱스: -1이 아닌 경우만 사용
                final bodyIndex = provider.characterBody;
                final eyeIndex = provider.characterEye;
                final colorIndex = provider.characterColor;
                //3. ⭐️ 배경색 결정 ⭐️
                //    - 초기 상태일 경우: grayscale10
                //    - 색상이 선택된 경우: 선택된 색상
                //    - 색상은 선택되지 않았지만 다른 요소가 선택된 경우: grayscale10 유지
                final containerColor = (isInitialState || colorIndex == -1)
                    ? AppColors.grayscale10
                    : CharacterColors.getBackgroundColor(colorIndex);
                
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: containerColor,
                  ),
                  child: Center(
                    // 4. ⭐️ 표시할 내용 결정 ⭐️
                    child: isInitialState 
                        ? Text(
                            '?',
                            style: AppTextStyles.header.copyWith(
                              fontSize: 80,
                              color: AppColors.grayscale30,
                              fontWeight:FontWeight.w700,
                            ),
                          )
                        : Stack(alignment: Alignment.center,
                            children: [
                              // 4-1. ⭐️ 모양 (Body)이 선택되었을 때만 렌더링 ⭐️
                              if (bodyIndex != -1)
                                Transform.scale(
                                  scale: 2.4,
                                  child: SvgPicture.asset(
                                    CharacterAssets.getBodyPath(bodyIndex),
                                    width: 60,
                                    height: 60,
                                    colorFilter: ColorFilter.mode(
                                      // 색상이 선택되었으면 선택된 색상, 아니면 grayscale30 적용
                                      colorIndex != -1 
                                          ? CharacterColors.getColor(colorIndex)
                                          : AppColors.grayscale30, 
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),

                              // 4-2. ⭐️ 눈 (Eye)이 선택되었을 때만 렌더링 ⭐️
                              if (eyeIndex != -1)
                                Transform.scale(
                                  scale: 2.4,
                                  child: SvgPicture.asset(
                                    CharacterAssets.getEyePath(eyeIndex),
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
                children: [
                  // ⭐️ [UPDATE] onSelect 콜백 전달: 모양 선택 시 -> 눈 탭으로 전환 ⭐️
                  _BodySelectionTab(onSelect: () => _switchToTab(CharacterTab.eye)),
                  // ⭐️ [UPDATE] onSelect 콜백 전달: 눈 선택 시 -> 색상 탭으로 전환 ⭐️
                  _EyeSelectionTab(onSelect: () => _switchToTab(CharacterTab.color)),
                  const _ColorSelectionTab(),
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
                        // ⭐️ [FIX] 다음 버튼 활성화 조건 추가: 모양, 눈, 색상 모두 -1이 아닐 때만 활성화 ⭐️
                        final bool isCharacterComplete = 
                            provider.characterBody != -1 && 
                            provider.characterEye != -1 && 
                            provider.characterColor != -1;

                        return AppButton(
                          label: '다음',
                          // isCharacterComplete가 true일 때만 nextStep 함수를 연결합니다.
                          onPressed: isCharacterComplete ? () => provider.nextStep() : null,
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

/// 캐릭터 몸 선택 탭
class _BodySelectionTab extends StatelessWidget {
  // ⭐️ [NEW] 선택 완료 후 호출될 콜백 함수 ⭐️
  final VoidCallback onSelect;
  const _BodySelectionTab({required this.onSelect});

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
                onTap: () {
                  provider.setCharacterBody(bodyIndex);
                  onSelect(); // ⭐️ 선택 후 다음 탭으로 전환 요청 ⭐️
                },
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
                          width: 60,
                          height: 60,
                          colorFilter: ColorFilter.mode(
                            AppColors.grayscale30,
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

/// 캐릭터 눈 선택 탭
class _EyeSelectionTab extends StatelessWidget {
  // ⭐️ [NEW] 선택 완료 후 호출될 콜백 함수 ⭐️
  final VoidCallback onSelect;
  const _EyeSelectionTab({required this.onSelect});

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
                onTap: () {
                  provider.setCharacterEye(eyeIndex);
                  onSelect(); // ⭐️ 선택 후 다음 탭으로 전환 요청 ⭐️
                },
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
                          width: 80,
                          height: 80,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
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

/// 캐릭터 색상 선택 탭
class _ColorSelectionTab extends StatelessWidget {
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
                    width: 46,
                    height: 46,
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