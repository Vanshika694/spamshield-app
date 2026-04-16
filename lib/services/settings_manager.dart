import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsManager {
  static const _kSpamAlerts = 'spam_alerts';
  static const _kAutoScan   = 'auto_scan';
  static const _kRealTime   = 'real_time_detection';
  static const _kLocalOnly  = 'local_only';
  static const _kDarkMode   = 'dark_mode';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme persistence
    bool isDark = prefs.getBool(_kDarkMode) ?? true;
    AppTheme.isDarkMode.value = isDark;
    
    // Hook listener to save theme changes
    AppTheme.isDarkMode.addListener(() async {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kDarkMode, AppTheme.isDarkMode.value);
    });
  }

  static Future<bool> getBool(String key, {bool defaultValue = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Helper getters for clarity
  static String get keySpamAlerts => _kSpamAlerts;
  static String get keyAutoScan   => _kAutoScan;
  static String get keyRealTime   => _kRealTime;
  static String get keyLocalOnly  => _kLocalOnly;
}
