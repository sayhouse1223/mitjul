import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/providers/onboarding_provider.dart';
import 'package:mitjul_app_new/components/index.dart'; // 

/// Step 1: 장르 선택 화면
class GenreSelectionScreen extends StatelessWidget {
  const GenreSelectionScreen({super.key});

  // 장르 목록
  static const List<String> genres = [
    '소설/문학',
    '에세이/시',
    '자기계발',
    '인문/철학',
    '경제/경영',
    '역사/문화',
    '여행',
    '과학/기술',
    '예술/취미',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // 타이틀
              Text(
                '어떤 장르를 좋아하세요?',
                style: AppTextStyles.header.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 서브타이틀
              Text(
                '최소 1개 이상 선택',
                style: AppTextStyles.body14R.copyWith(
                  color: AppColors.grayscale60,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 장르 선택 그리드 및 '모두 선택' 체크박스
              Expanded(
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, child) {
                    final isAllSelected = provider.selectedGenres.length == genres.length;
                    
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. 장르 칩 목록
                          Wrap(
                            spacing: 12,
                            runSpacing: 12, 
                            children: genres.map((genre) {
                              final isSelected = provider.selectedGenres.contains(genre);
                              return AppChip(
                                label: genre,
                                isSelected: isSelected,
                                onTap: () => provider.toggleGenre(genre),
                                // ⭐️ 스타일과 사이즈 지정 ⭐️
                                style: ChipStyle.fill, // 스타일 (기존 장르칩 모양)
                                size: ChipSize.large, //  사이즈 (얇은 두께)
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 24), // 칩 목록과 체크박스 사이 간격
                          
                          // 2. AllSelectChip 컴포넌트 사용
                          AllSelectChip(
                            isSelected: isAllSelected,
                            onTap: () {
                              if (isAllSelected) {
                                provider.deselectAllGenres();
                              } else {
                                provider.selectAllGenres(genres);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),// 다음 버튼 (하단 고정)
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  final canProceed = provider.selectedGenres.isNotEmpty;
                  
                  // ⭐️ AppButton의 닫는 괄호 ')'를 추가합니다. ⭐️
                  return AppButton(
                    label: '다음',
                    onPressed: canProceed ? () => provider.nextStep() : null,
                    type: ButtonType.primaryFill, // Primary
                    isLarge: true,            // Large (기본값이라 생략 가능)
                  ); // <--- 여기가 AppButton의 닫는 괄호
                }, // <--- 여기가 builder 함수의 닫는 중괄호
              ), // <--- 여기가 Consumer 위젯의 닫는 괄호와 쉼표
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
