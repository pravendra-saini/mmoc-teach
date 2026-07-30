import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';

class MMOCTeachApp extends StatelessWidget {
  const MMOCTeachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MMOC TEACH',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}