import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/diary.dart';
import 'screens/intro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/cover_generator_screen.dart';

void main() {
  runApp(const AuroraDiariesApp());
}

class AuroraDiariesApp extends StatelessWidget {
  const AuroraDiariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Diaries',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const IntroScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/editor':
            final diary = settings.arguments as Diary;
            return MaterialPageRoute(
              builder: (_) => EditorScreen(diary: diary),
            );
          case '/cover-generator':
            final diary = settings.arguments as Diary;
            return MaterialPageRoute(
              builder: (_) => CoverGeneratorScreen(diary: diary),
            );
          default:
            return MaterialPageRoute(builder: (_) => const IntroScreen());
        }
      },
    );
  }
}
