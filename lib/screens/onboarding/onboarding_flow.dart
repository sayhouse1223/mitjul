import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mitjul_app_new/providers/onboarding_provider.dart';
import 'package:mitjul_app_new/screens/onboarding/genre_selection_screen.dart';
import 'package:mitjul_app_new/screens/onboarding/character_setup_screen.dart';
import 'package:mitjul_app_new/screens/onboarding/nickname_screen.dart';

/// 온보딩 플로우 메인 화면
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          // 현재 스텝에 따라 화면 전환
          switch (provider.currentStep) {
            case 0:
              return const GenreSelectionScreen();
            case 1:
              return const CharacterSetupScreen();
            case 2:
              return const NicknameScreen();
            default:
              return const GenreSelectionScreen();
          }
        },
      ),
    );
  }
}