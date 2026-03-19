import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ LIVE — works 24/7 from anywhere without laptop!
  // Render deployment: https://spamshield-backend-zfb1.onrender.com
  // Local fallback:    http://10.129.55.42:5000/api/auth
  static const String _baseUrl = 'https://spamshield-backend-zfb1.onrender.com/api/auth';

  // ─── SharedPreferences keys ───────────────────────────────────
  static const _kToken     = 'auth_token';
  static const _kName      = 'user_name';
  static const _kEmail     = 'user_email';
  static const _kPassword  = 'user_password'; // local fallback only
  static const _kId        = 'user_id';

  // ─── Session helpers ──────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken) != null;
  }

  static Future<void> _saveLocal({
    required String name,
    required String email,
    required String password,
    String token = '',
    String id = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName,     name);
    await prefs.setString(_kEmail,    email);
    await prefs.setString(_kPassword, password);
    await prefs.setString(_kToken,    token.isNotEmpty ? token : 'local_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString(_kId,       id);
  }

  // ─── SIGN UP ─────────────────────────────────────────────────
  static Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String phone = '',
  }) async {
    // Basic validation first
    if (name.trim().isEmpty) return AuthResult(success: false, error: 'Name is required.');
    if (!email.contains('@'))  return AuthResult(success: false, error: 'Enter a valid email.');
    if (password.length < 6)   return AuthResult(success: false, error: 'Password must be at least 6 characters.');
    if (password != confirmPassword) return AuthResult(success: false, error: 'Passwords do not match.');

    // Try backend
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'phone': phone}),
      ).timeout(const Duration(seconds: 6));

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        await _saveLocal(
          name: name, email: email, password: password,
          token: data['token'] ?? '', id: data['user']?['id'] ?? '',
        );
        return AuthResult(success: true);
      }
      return AuthResult(success: false, error: data['message'] ?? 'Registration failed.');
    } catch (_) {
      // ─── OFFLINE FALLBACK: save locally ──────────────────────
      await _saveLocal(name: name, email: email, password: password);
      return AuthResult(success: true, isOffline: true);
    }
  }

  // ─── SIGN IN ─────────────────────────────────────────────────
  static Future<AuthResult> signIn(String email, String password) async {
    if (email.isEmpty || !email.contains('@'))
      return AuthResult(success: false, error: 'Enter a valid email address.');
    if (password.length < 6)
      return AuthResult(success: false, error: 'Password must be at least 6 characters.');

    // Try backend
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 6));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        await _saveLocal(
          name: data['user']?['name'] ?? '', email: email, password: password,
          token: data['token'] ?? '', id: data['user']?['id'] ?? '',
        );
        return AuthResult(success: true);
      }
      return AuthResult(success: false, error: data['message'] ?? 'Login failed.');
    } catch (_) {
      // ─── OFFLINE FALLBACK: check local credentials ────────────
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString(_kEmail)    ?? '';
      final storedPass  = prefs.getString(_kPassword) ?? '';

      if (storedEmail.isEmpty) {
        return AuthResult(success: false, error: 'No account found. Please sign up first.');
      }
      if (storedEmail == email && storedPass == password) {
        // Refresh local token
        await prefs.setString(_kToken, 'local_${DateTime.now().millisecondsSinceEpoch}');
        return AuthResult(success: true, isOffline: true);
      }
      return AuthResult(success: false, error: 'Incorrect email or password.');
    }
  }

  // ─── FORGOT PASSWORD ─────────────────────────────────────────
  static Future<AuthResult> sendResetLink(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!email.contains('@')) return AuthResult(success: false, error: 'Enter a valid email.');
    return AuthResult(success: true);
  }

  // ─── GET USER (from local cache) ─────────────────────────────
  static Future<UserProfile> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      id:    prefs.getString(_kId)    ?? '',
      name:  prefs.getString(_kName)  ?? 'User',
      email: prefs.getString(_kEmail) ?? '',
    );
  }

  // ─── SIGN OUT ────────────────────────────────────────────────
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kId);
    // Keep name/email/password for next login
  }
}

class AuthResult {
  final bool success;
  final bool isOffline; // true = worked but without server
  final String? error;
  AuthResult({required this.success, this.error, this.isOffline = false});
}

class UserProfile {
  final String id, name, email;
  UserProfile({required this.id, required this.name, required this.email});
}
