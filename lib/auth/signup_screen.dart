import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _captchaCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _agreed         = false;
  bool _loading        = false;
  String? _error;
  double _passStrength = 0;

  // ── CAPTCHA ────────────────────────────────────────────────────
  String _captchaCode = '';
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _refreshCaptcha();
    _passCtrl.addListener(_updatePasswordStrength);
  }

  void _refreshCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789abcdefghjkmnpqrstuvwxyz';
    final rng = Random();
    setState(() {
      _captchaCode = List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
      _captchaCtrl.clear();
    });
  }

  void _updatePasswordStrength() {
    final p = _passCtrl.text;
    double score = 0;
    if (p.length >= 8)                                   score += 0.25;
    if (p.length >= 12)                                  score += 0.10;
    if (RegExp(r'[A-Z]').hasMatch(p))                    score += 0.20;
    if (RegExp(r'[0-9]').hasMatch(p))                    score += 0.20;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score += 0.25;
    setState(() => _passStrength = score.clamp(0.0, 1.0));
  }

  String get _passStrengthLabel {
    if (_passStrength < 0.30) return 'Weak';
    if (_passStrength < 0.60) return 'Fair';
    if (_passStrength < 0.85) return 'Good';
    return 'Strong';
  }

  Color get _passStrengthColor {
    if (_passStrength < 0.30) return AppTheme.spamRed;
    if (_passStrength < 0.60) return Colors.orange;
    if (_passStrength < 0.85) return Colors.amber;
    return Colors.green;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _phoneCtrl.dispose(); _captchaCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Validate password policy ────────────────────────────────────
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include at least one uppercase letter (A-Z)';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Include at least one lowercase letter (a-z)';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number (0-9)';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
      return 'Include at least one special character (!@#\$...)';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // CAPTCHA check
    if (_captchaCtrl.text.trim() != _captchaCode) {
      setState(() => _error = 'Incorrect CAPTCHA. Please try again.');
      _refreshCaptcha();
      return;
    }

    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms & Privacy Policy.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final result = await AuthService.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => const HomeScreen(),
          transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (r) => false,
      );
    } else {
      setState(() => _error = result.error);
      _refreshCaptcha();
    }
  }

  // ── FIX: back button goes to SignIn not black screen ───────────
  void _goBack() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const SignInScreen(),
        transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // ── Back button (FIXED) ──
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 15, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Create account',
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('Join SpamShield and stay protected',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                  const SizedBox(height: 32),

                  // Name
                  _field(controller: _nameCtrl, label: 'Full name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v!.trim().isEmpty ? 'Name required' : null),
                  const SizedBox(height: 12),
                  // Email
                  _field(controller: _emailCtrl, label: 'Email address',
                      icon: Icons.mail_outline_rounded,
                      keyboard: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'Valid email required' : null),
                  const SizedBox(height: 12),
                  // Phone
                  _field(controller: _phoneCtrl, label: 'Phone number (optional)',
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 12),

                  // ── Password with strength indicator ────────────
                  _passField(controller: _passCtrl, label: 'Password',
                      obscure: _obscurePass,
                      toggle: () => setState(() => _obscurePass = !_obscurePass),
                      validator: _validatePassword),
                  if (_passCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildPasswordStrength(),
                  ],
                  const SizedBox(height: 12),

                  // Confirm Password
                  _passField(controller: _confirmCtrl, label: 'Confirm password',
                      obscure: _obscureConfirm,
                      toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
                  const SizedBox(height: 20),

                  // ── CAPTCHA ─────────────────────────────────────
                  _buildCaptcha(),
                  const SizedBox(height: 16),

                  // T&C checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22, height: 22,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          activeColor: AppTheme.accent,
                          checkColor: AppTheme.bg,
                          side: BorderSide(color: AppTheme.border, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(text: 'Terms of Service',
                                  style: GoogleFonts.inter(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy',
                                  style: GoogleFonts.inter(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _errorBanner(_error!),
                  ],
                  const SizedBox(height: 24),

                  // Create Account button
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppTheme.accent.withValues(alpha: 0.22),
                              blurRadius: 16, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Create Account',
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
                      GestureDetector(
                        onTap: _goBack,
                        child: Text('Sign In',
                            style: GoogleFonts.inter(
                                color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Password Strength Bar ────────────────────────────────────────
  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _passStrength,
            backgroundColor: AppTheme.surface,
            valueColor: AlwaysStoppedAnimation(_passStrengthColor),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Password strength: ',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
            Text(_passStrengthLabel,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _passStrengthColor)),
            const Spacer(),
            Text('Min 8 chars • A-Z • 0-9 • !@#',
                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ],
    );
  }

  // ── CAPTCHA Widget (alphanumeric) ──────────────────────────────
  Widget _buildCaptcha() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_outlined, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Text('Security Check — type the code below',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Styled CAPTCHA code display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF38BDF8), Colors.white],
                      ).createShader(bounds),
                      child: Text(
                        _captchaCode,
                        style: GoogleFonts.robotoMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _refreshCaptcha,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textMuted),
                tooltip: 'New code',
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _captchaCtrl,
            style: GoogleFonts.robotoMono(color: AppTheme.textPrimary, fontSize: 15,
                fontWeight: FontWeight.w600, letterSpacing: 3),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Enter code above',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter the CAPTCHA code';
              if (v.trim() != _captchaCode) return 'Incorrect code — try again';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        ),
      ),
      validator: validator,
    );
  }

  Widget _errorBanner(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.spamRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.spamRed.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppTheme.spamRed, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: GoogleFonts.inter(color: AppTheme.spamRed, fontSize: 12))),
        ]),
      );
}
