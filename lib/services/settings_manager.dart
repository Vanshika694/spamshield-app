import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const _kSpamAlerts = 'spam_alerts';
  static const _kAutoScan   = 'auto_scan';
  static const _kRealTime   = 'real_time_detection';
  static const _kLocalOnly  = 'local_only';
  static Future<void> init() async {
    // No-op for now, but kept for consistency
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
