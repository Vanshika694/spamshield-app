import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web Client ID from Google Cloud Console
    serverClientId: '991102462359-dguj0hp4cbmuuc5m16kidn6t09ns9a1k.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Shows the Google account picker and returns auth result
  static Future<GoogleAuthResult> signIn() async {
    try {
      // Sign out first to always show account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the picker
        return GoogleAuthResult(cancelled: true);
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        return GoogleAuthResult(
          error: 'Could not get Google ID token. Please try again.',
        );
      }

      return GoogleAuthResult(
        idToken: idToken,
        name: account.displayName ?? 'User',
        email: account.email,
        photoUrl: account.photoUrl,
        googleId: account.id,
      );
    } catch (e) {
      return GoogleAuthResult(
        error: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

class GoogleAuthResult {
  final String? idToken;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? googleId;
  final String? error;
  final bool cancelled;

  GoogleAuthResult({
    this.idToken,
    this.name,
    this.email,
    this.photoUrl,
    this.googleId,
    this.error,
    this.cancelled = false,
  });

  bool get success => idToken != null && error == null && !cancelled;
}
