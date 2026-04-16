import 'package:flutter/material.dart';
import 'auth/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/settings_manager.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await SettingsManager.init();
  runApp(const SpamShieldApp());
}

class SpamShieldApp extends StatelessWidget {
  const SpamShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppTheme.isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'SpamShield',
          debugShowCheckedModeBanner: false,
          theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
