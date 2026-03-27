import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../auth/signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _spamNotifications = true;
  bool _autoScan          = true;
  bool _darkMode          = true;
  bool _realTimeDetection = true;
  bool _localOnly         = true;
  String _userName  = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await AuthService.getUser();
    if (mounted) setState(() { _userName = u.name; _userEmail = u.email; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text('Account & Settings',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildProfileCard(),
            const SizedBox(height: 22),
            _buildSection('Notifications', [
              _ToggleTile(icon: Icons.notifications_active_outlined, title: 'Spam Alerts',
                  subtitle: 'Get notified when spam is detected',
                  value: _spamNotifications, activeColor: AppTheme.accent,
                  onChanged: (v) => setState(() => _spamNotifications = v)),
            ]),
            const SizedBox(height: 14),
            _buildSection('Detection', [
              _ToggleTile(icon: Icons.autorenew_rounded, title: 'Auto Scan',
                  subtitle: 'Automatically scan incoming SMS',
                  value: _autoScan, activeColor: AppTheme.hamGreen,
                  onChanged: (v) => setState(() => _autoScan = v)),
              _ToggleTile(icon: Icons.bolt_rounded, title: 'Real-Time Detection',
                  subtitle: 'Instant analysis as messages arrive',
                  value: _realTimeDetection, activeColor: AppTheme.hamGreen,
                  onChanged: (v) => setState(() => _realTimeDetection = v)),
            ]),
            const SizedBox(height: 14),
            _buildSection('Privacy', [
              _ToggleTile(icon: Icons.shield_outlined, title: 'Local Processing Only',
                  subtitle: 'Messages never leave your device',
                  value: _localOnly, activeColor: AppTheme.accent,
                  onChanged: (v) => setState(() => _localOnly = v)),
              _ToggleTile(icon: Icons.dark_mode_outlined, title: 'Dark Mode',
                  subtitle: 'Cybersecurity-inspired dark theme',
                  value: _darkMode, activeColor: AppTheme.purple,
                  onChanged: (v) => setState(() => _darkMode = v)),
            ]),
            const SizedBox(height: 14),
            _buildSection('General', [
              _ActionTile(icon: Icons.delete_outline_rounded, title: 'Clear Message History',
                  subtitle: 'Remove all analyzed data',
                  color: AppTheme.spamRed,
                  onTap: () => _showClearDialog()),
              _ActionTile(icon: Icons.info_outline_rounded, title: 'About SpamShield',
                  subtitle: 'Version 1.0.0 • Build 2026.03',
                  color: AppTheme.textSecondary,
                  onTap: () => _showAbout()),
            ]),
            const SizedBox(height: 22),
            // Logout
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.spamRed.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.spamRed.withValues(alpha: 0.25)),
              ),
              child: TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: AppTheme.spamRed, size: 18),
                label: Text('Sign Out',
                    style: GoogleFonts.inter(color: AppTheme.spamRed, fontWeight: FontWeight.w600, fontSize: 14)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.4),
            AppTheme.cardAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userName.isEmpty ? 'User' : _userName,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(_userEmail.isEmpty ? '—' : _userEmail,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.hamGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Protected',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.hamGreen, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 18),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(title.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted, letterSpacing: 1.2)),
        ),
        Container(
          decoration: AppTheme.glassCard(radius: 14),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final isLast = e.key == tiles.length - 1;
              return Column(children: [
                e.value,
                if (!isLast) Divider(height: 1, color: AppTheme.border.withValues(alpha: 0.5), indent: 52),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Sign Out?', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('You will be returned to the login screen.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Sign Out', style: GoogleFonts.inter(color: AppTheme.spamRed, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (r) => false,
      );
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Clear History?', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('All analyzed message data will be deleted permanently.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Clear', style: GoogleFonts.inter(color: AppTheme.spamRed, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SpamShield',
      applicationVersion: '1.0.0 (2026.03)',
      applicationIcon: const Icon(Icons.security, color: AppTheme.accent, size: 36),
      children: [
        Text('A mobile security suite combining SMS spam detection\nand comprehensive device protection.',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle,
      required this.value, required this.activeColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final col = value ? activeColor : AppTheme.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: col, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
          ],
        )),
        Switch(
          value: value, onChanged: onChanged,
          activeThumbColor: activeColor,
          activeTrackColor: activeColor.withValues(alpha: 0.25),
          inactiveThumbColor: AppTheme.textMuted,
          inactiveTrackColor: AppTheme.surface,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.title, required this.subtitle,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
          ],
        )),
        Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
      ]),
    ),
  );
}
