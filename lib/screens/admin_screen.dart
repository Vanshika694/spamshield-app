import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        automaticallyImplyLeading: false,
        leading:
            const Icon(Icons.admin_panel_settings, color: AppTheme.accent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildAdminHeader(),
            const SizedBox(height: 20),
            // Stats Grid
            _buildStatGrid(),
            const SizedBox(height: 20),
            // Detection accuracy bar
            _buildAccuracyCard(),
            const SizedBox(height: 20),
            // Flagged messages
            _buildFlaggedSection(),
            const SizedBox(height: 20),
            // Admin actions
            _buildAdminActions(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.6),
            AppTheme.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
              Text('Last updated: Today, 11:00 AM',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  )),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.hamGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.hamGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('Live',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.hamGreen,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = [
      {'label': 'Total Users', 'value': '1,284', 'icon': Icons.people_outline, 'color': AppTheme.accent},
      {'label': 'Analyzed', 'value': '312K', 'icon': Icons.message_outlined, 'color': AppTheme.primary},
      {'label': 'Spam Caught', 'value': '58.9K', 'icon': Icons.dangerous_outlined, 'color': AppTheme.spamRed},
      {'label': 'Model v2.4', 'value': '96.4%', 'icon': Icons.psychology_outlined, 'color': AppTheme.hamGreen},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final s = stats[i];
        final color = s['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(s['icon'] as IconData, color: color, size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['value'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color,
                      )),
                  Text(s['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Detection Accuracy',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
              const Spacer(),
              Text('96.4%',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.964,
              backgroundColor: AppTheme.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _AccuracyItem(label: 'Precision', value: '97.1%', color: AppTheme.hamGreen),
              const SizedBox(width: 16),
              _AccuracyItem(label: 'Recall', value: '95.8%', color: AppTheme.primary),
              const SizedBox(width: 16),
              _AccuracyItem(label: 'F1 Score', value: '96.4%', color: AppTheme.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggedSection() {
    final flagged = [
      {'sender': '+1 800 CASH', 'reason': 'Prize Scam', 'count': 23},
      {'sender': 'LOANOFFER', 'reason': 'Phishing', 'count': 15},
      {'sender': '+44 700 FREE', 'reason': 'Suspicious Link', 'count': 8},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Flagged Senders',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
        const SizedBox(height: 10),
        ...flagged.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.spamRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: AppTheme.spamRed, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['sender'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            )),
                        Text(f['reason'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.spamRed,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.spamRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${f['count']} msgs',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.spamRed,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    final actions = [
      {'icon': Icons.people_outline, 'label': 'Manage Users', 'color': AppTheme.accent},
      {'icon': Icons.report_outlined, 'label': 'Spam Reports', 'color': AppTheme.spamRed},
      {'icon': Icons.model_training, 'label': 'Update Model', 'color': AppTheme.primary},
      {'icon': Icons.download_outlined, 'label': 'Export Data', 'color': AppTheme.hamGreen},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Actions',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: actions.length,
          itemBuilder: (_, i) {
            final a = actions[i];
            final color = a['color'] as Color;
            return GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${a['label']} tapped!',
                      style: GoogleFonts.inter()),
                  backgroundColor: AppTheme.card,
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(a['icon'] as IconData, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(a['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccuracyItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AccuracyItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            )),
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textSecondary,
            )),
      ],
    );
  }
}
