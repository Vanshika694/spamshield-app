import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading    = false;
  bool _sent       = false;
  String? _error;

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final result = await AuthService.sendResetLink(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() { _loading = false; _sent = result.success; _error = result.error; });
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 32),
              // Lock icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: AppTheme.accent, size: 28),
              ),
              const SizedBox(height: 20),
              Text('Forgot password?',
                  style: GoogleFonts.inter(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary, letterSpacing: -0.5,
                  )),
              const SizedBox(height: 8),
              Text("No worries. Enter your registered email and we'll send you a reset link.",
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 32),

              if (!_sent) ...[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.spamRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.spamRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppTheme.spamRed, size: 16),
                      const SizedBox(width: 8),
                      Text(_error!, style: GoogleFonts.inter(color: AppTheme.spamRed, fontSize: 12)),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Send Reset Link',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ),
              ] else ...[
                // Success state
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.hamGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.hamGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_outlined,
                            color: AppTheme.hamGreen, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text('Check your email!',
                          style: GoogleFonts.inter(
                              fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        'A password reset link has been sent to\n${_emailCtrl.text.trim()}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Back to Sign In',
                        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
