import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
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
  bool _isGranted = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050D1F), Color(0xFF071428)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: AppTheme.accent),
                      ),
                    ),
                    const Spacer(),
                    Text('Step 1 of 1',
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                const Spacer(flex: 1),
                // Scanner illustration
                _buildScanIllustration(),
                const SizedBox(height: 40),
                // Title
                Text(
                  'SMS Access Needed',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'SpamShield needs access to your SMS messages to analyze and detect spam. Your messages are processed locally and never leave your device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 28),
                // Privacy card
                _buildPrivacyCard(),
                const Spacer(flex: 2),
                // Grant button
                _buildGrantButton(context),
                const SizedBox(height: 16),
                Text(
                  '🔒  Your data stays secure and is only analyzed locally.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
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
            border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.5), width: 2),
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: List.generate(
                5,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Scan line
        AnimatedBuilder(
          animation: _scanLine,
          builder: (context, _) {
            return Positioned(
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
            );
          },
        ),
        // Shield overlay
        Positioned(
          right: 60,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.hamGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.check, color: AppTheme.hamGreen, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.hamGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.25)),
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
                color: AppTheme.hamGreen, size: 20),
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
                      fontSize: 13,
                    )),
                Text('No data is ever uploaded to servers',
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrantButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.hamGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() => _isGranted = true);
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, a, b) => const HomeScreen(),
                    transitionsBuilder: (_, a, b, child) =>
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: a, curve: Curves.easeOut)),
                          child: child,
                        ),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                );
              }
            });
          },
          icon: Icon(
            _isGranted ? Icons.check_circle : Icons.message_outlined,
            color: Colors.white,
          ),
          label: Text(
            _isGranted ? 'Access Granted!' : 'Grant SMS Access',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
