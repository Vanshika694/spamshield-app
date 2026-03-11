import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SpamShieldApp());
}

class SpamShieldApp extends StatelessWidget {
  const SpamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpamShield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
