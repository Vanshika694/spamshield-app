import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/sms_service.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanLine;

  // Permission state
  bool _requesting = false;
  bool _denied     = false;
  bool _permanent  = false; // permanently denied

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanLine = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  // ─── Main permission request flow ─────────────────────────────
  Future<void> _requestSmsPermission() async {
    setState(() { _requesting = true; _denied = false; _permanent = false; });

    // ✅ This line triggers the REAL Android system permission popup
    final status = await Permission.sms.request();

    setState(() => _requesting = false);

    if (status.isGranted) {
      // Permission granted — go to home
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => const HomeScreen(),
          transitionsBuilder: (_, a, b, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      setState(() { _denied = true; _permanent = true; });
    } else {
      setState(() => _denied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.surface,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 15, color: AppTheme.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  Text('Step 1 of 1',
                      style: GoogleFonts.inter(
                          color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
              const Spacer(flex: 1),
              // Scanner illustration
              _buildScanIllustration(),
              const SizedBox(height: 40),
              // Title
              Text(
                'Allow SMS Access',
                style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary, letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'SpamShield needs to read your SMS messages to detect spam. All analysis happens locally on your device — your messages are never uploaded.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.textSecondary, height: 1.65),
              ),
              const SizedBox(height: 24),

              // Privacy card
              _buildPrivacyCard(),

              // Error / denied banner
              if (_denied) ...[
                const SizedBox(height: 14),
                _buildDeniedBanner(),
              ],

              const Spacer(flex: 2),

              // Grant button
              _buildGrantButton(),
              const SizedBox(height: 14),
              Text(
                '🔒  Your messages stay on your device.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Phone outline
        Container(
          width: 130,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4), width: 2),
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: i == 2 ? 0.55 : 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
            ),
          ),
        ),
        // Animated scan line
        AnimatedBuilder(
          animation: _scanLine,
          builder: (context, _) => Positioned(
            top: 20 + (_scanLine.value * 160),
            child: Container(
              width: 126,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.accent.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                  )
                ],
              ),
            ),
          ),
        ),
        // Checkmark badge
        Positioned(
          right: 54,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.hamGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.check, color: AppTheme.hamGreen, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.hamGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.hamGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user_outlined,
                color: AppTheme.hamGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy First',
                    style: GoogleFonts.inter(
                        color: AppTheme.hamGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text('No SMS data is ever sent to any server',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeniedBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.spamRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.spamRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: AppTheme.spamRed, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _permanent
                      ? 'Permission permanently blocked. Please enable it in your phone\'s Settings → Apps → SpamShield → Permissions.'
                      : 'SMS permission was denied. Tap below to try again.',
                  style: GoogleFonts.inter(
                      color: AppTheme.spamRed, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
          if (_permanent) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => SmsService.openSettings(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.spamRed.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('Open App Settings',
                    style: GoogleFonts.inter(color: AppTheme.spamRed, fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrantButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: _denied
                ? [AppTheme.warnYellow, const Color(0xFFF97316)]
                : [const Color(0xFF22C55E), const Color(0xFF16A34A)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_denied ? AppTheme.warnYellow : AppTheme.hamGreen)
                  .withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _requesting ? null : _requestSmsPermission,
          icon: _requesting
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Icon(
                  _denied ? Icons.refresh_rounded : Icons.message_rounded,
                  color: Colors.white,
                  size: 20,
                ),
          label: Text(
            _requesting
                ? 'Requesting...'
                : _denied
                    ? 'Try Again'
                    : 'Grant SMS Access',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}
