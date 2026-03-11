import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn  = 'is_logged_in';
  static const _keyUserName  = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyToken     = 'auth_token';

  // Check if user is already logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // Sign In — validates locally stored credentials
  static Future<AuthResult> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900)); // Simulate network
    if (email.isEmpty || !email.contains('@')) {
      return AuthResult(success: false, error: 'Enter a valid email address.');
    }
    if (password.length < 6) {
      return AuthResult(success: false, error: 'Password must be at least 6 characters.');
    }
    final prefs = await SharedPreferences.getInstance();
    final storedEmail    = prefs.getString(_keyUserEmail) ?? '';
    final storedPassword = prefs.getString('user_password') ?? '';

    // If no account exists yet, auto-create on first login
    if (storedEmail.isEmpty) {
      return AuthResult(success: false, error: 'No account found. Please sign up first.');
    }
    if (storedEmail != email || storedPassword != password) {
      return AuthResult(success: false, error: 'Incorrect email or password.');
    }

    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyToken, 'tok_${DateTime.now().millisecondsSinceEpoch}');
    return AuthResult(success: true);
  }

  // Sign Up — store credentials locally
  static Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (name.trim().isEmpty) return AuthResult(success: false, error: 'Name is required.');
    if (!email.contains('@')) return AuthResult(success: false, error: 'Enter a valid email.');
    if (password.length < 6)  return AuthResult(success: false, error: 'Password must be at least 6 characters.');
    if (password != confirmPassword) return AuthResult(success: false, error: 'Passwords do not match.');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name.trim());
    await prefs.setString(_keyUserEmail, email.trim());
    await prefs.setString('user_password', password);
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyToken, 'tok_${DateTime.now().millisecondsSinceEpoch}');
    return AuthResult(success: true);
  }

  // Forgot password — simulate sending email
  static Future<AuthResult> sendResetLink(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!email.contains('@')) return AuthResult(success: false, error: 'Enter a valid email.');
    return AuthResult(success: true);
  }

  // Sign Out
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.remove(_keyToken);
  }

  // Get current user info
  static Future<UserProfile> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name:  prefs.getString(_keyUserName)  ?? 'User',
      email: prefs.getString(_keyUserEmail) ?? '',
    );
  }
}

class AuthResult {
  final bool success;
  final String? error;
  AuthResult({required this.success, this.error});
}

class UserProfile {
  final String name;
  final String email;
  UserProfile({required this.name, required this.email});
}
