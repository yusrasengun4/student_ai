// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/daily_analysis_page.dart';
import 'pages/profile_page.dart';
import 'pages/weekly_report_page.dart';
import 'models/user_model.dart';

void main() => runApp(const EduBoostApp());

class EduBoostApp extends StatelessWidget {
  const EduBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBoost AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        final user = settings.arguments as UserModel?;
        switch (settings.name) {
          case '/daily':   return MaterialPageRoute(builder: (_) => DailyAnalysisPage(user: user!));
          case '/profile': return MaterialPageRoute(builder: (_) => ProfilePage(user: user!));
          case '/weekly': return MaterialPageRoute(
              builder: (_) => WeeklyReportPage(user: user!));
        }
        return null;
      },
    );
  }
}