import 'package:flutter/material.dart';
import 'package:mitjul_app_new/constants/colors.dart';
import 'package:mitjul_app_new/constants/text_styles.dart';
import 'package:mitjul_app_new/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MitjulApp());
}


class MitjulApp extends StatelessWidget {
  const MitjulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '밑줄 (Mitjul)',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        fontFamily: 'Suit',
        useMaterial3: true,
        colorScheme: ColorScheme.light(  
          primary: AppColors.primary0,
          secondary: AppColors.secondary0,
          surface: AppColors.background,
          error: AppColors.point1Error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.header,
        ),
      ),
      
      darkTheme: ThemeData(
        fontFamily: 'Suit',
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary0,
          secondary: AppColors.secondary0,
          surface: AppColors.backgroundDark,
          error: AppColors.point1Error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.header.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
      
      themeMode: ThemeMode.system,
      
      home: const SplashScreen(),
    );
  }
}
// 스플래시 화면
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후 로그인 화면으로 이동
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: Image.asset(
          'assets/images/splash_screen.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
