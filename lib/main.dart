import 'package:flutter/material.dart';
import 'auth/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/settings_manager.dart';
import 'services/notification_service.dart';
import 'package:flutter_embedder/flutter_embedder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await SettingsManager.init();
  // await RustLib.init();
  await initFlutterEmbedder();
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
