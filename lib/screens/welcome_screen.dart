import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'permission_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _shieldScale;
  late Animation<double> _pulseOpacity;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _shieldScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050D1F), Color(0xFF071428), Color(0xFF050D1F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // Shield Hero Illustration
                  _buildShieldHero(),
                  const SizedBox(height: 40),
                  // App Name + Tagline
                  _buildTitle(),
                  const Spacer(flex: 2),
                  // Features
                  _buildFeatureRow(),
                  const Spacer(flex: 1),
                  // Buttons
                  _buildButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        AnimatedBuilder(
          animation: _pulseOpacity,
          builder: (context, child) => Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: _pulseOpacity.value),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Inner circle
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.4),
                AppTheme.bg.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        // Shield icon
        AnimatedBuilder(
          animation: _shieldScale,
          builder: (context, child) => Transform.scale(
            scale: _shieldScale.value,
            child: const Icon(
              Icons.security,
              size: 70,
              color: AppTheme.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'SpamShield',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF3D91FF)],
              ).createShader(const Rect.fromLTWH(0, 0, 220, 50)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SMS Spam Detector',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.accent.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Automatically detect spam messages\nand protect your inbox with AI.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _featurePill(Icons.bolt, 'Real-Time'),
        _featurePill(Icons.lock_outline, 'Private'),
        _featurePill(Icons.analytics_outlined, 'Analytics'),
      ],
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(30),
        color: AppTheme.card,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Get Started
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF00B8D9), Color(0xFF1565C0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, a, b) => const PermissionScreen(),
                  transitionsBuilder: (_, a, b, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Learn More
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => _showLearnMoreDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.accent.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Learn More',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLearnMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'How SpamShield Works',
          style: GoogleFonts.inter(
            color: AppTheme.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _learnMoreItem(Icons.message_outlined, 'Reads your SMS messages with permission'),
            _learnMoreItem(Icons.psychology_outlined, 'Uses ML to classify Spam vs Ham'),
            _learnMoreItem(Icons.bar_chart, 'Shows detailed analytics & insights'),
            _learnMoreItem(Icons.shield_outlined, 'All processing done locally on device'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!',
                style: GoogleFonts.inter(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  Widget _learnMoreItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}
