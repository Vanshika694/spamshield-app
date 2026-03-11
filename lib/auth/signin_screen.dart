import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure   = true;
  bool _loading   = false;
  String? _error;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final result = await AuthService.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => const HomeScreen(),
          transitionsBuilder: (_, a, b, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (r) => false,
      );
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildFields(),
                  const SizedBox(height: 28),
                  _buildSignInButton(),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildGoogleButton(),
                  const SizedBox(height: 36),
                  _buildSignUpLink(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.security, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 24),
        Text('Welcome back',
            style: GoogleFonts.inter(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary, letterSpacing: -0.5,
            )),
        const SizedBox(height: 6),
        Text('Sign in to protect your device',
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        // Email
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
          validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
        ),
        const SizedBox(height: 14),
        // Password
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
        ),
        const SizedBox(height: 10),
        // Error
        if (_error != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.spamRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.spamRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppTheme.spamRed, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                    style: GoogleFonts.inter(color: AppTheme.spamRed, fontSize: 12))),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
            child: Text('Forgot password?',
                style: GoogleFonts.inter(color: AppTheme.accent, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.25),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Sign In',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Google Sign-In coming soon!',
                style: GoogleFonts.inter()),
            backgroundColor: AppTheme.surface,
          ));
        },
        icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: AppTheme.textPrimary),
        label: Text('Continue with Google',
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
          child: Text('Create Account',
              style: GoogleFonts.inter(
                  color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }
}
