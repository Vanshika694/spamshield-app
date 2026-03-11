import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': '+91 98765 43210',
      'content': 'Congratulations! You\'ve won a ₹50,000 prize. Click here to claim now before it expires! Limited time offer.',
      'isSpam': true,
      'confidence': 0.97,
      'time': '09:23 AM',
      'date': 'Today',
    },
    {
      'sender': 'Mom',
      'content': 'Are you coming home for dinner tonight? I\'m making your favourite biryani 😊',
      'isSpam': false,
      'confidence': 0.99,
      'time': '08:45 AM',
      'date': 'Today',
    },
    {
      'sender': 'HDFC Bank',
      'content': 'Dear Customer, your account ending 4532 has been credited with ₹5,000 on 09/03/2026.',
      'isSpam': false,
      'confidence': 0.95,
      'time': '07:30 AM',
      'date': 'Today',
    },
    {
      'sender': '+1 800 FREE',
      'content': 'URGENT: Click here to claim your FREE iPhone 15. You are the lucky winner. Act NOW!',
      'isSpam': true,
      'confidence': 0.99,
      'time': '06:15 AM',
      'date': 'Today',
    },
    {
      'sender': 'Dr Sharma Clinic',
      'content': 'Your appointment is confirmed for tomorrow at 10:30 AM. Please bring your reports.',
      'isSpam': false,
      'confidence': 0.98,
      'time': 'Yesterday',
      'date': 'Yesterday',
    },
    {
      'sender': 'LOAN OFFER',
      'content': 'Get instant personal loan of up to ₹5 Lakhs! No documents required. Apply now!',
      'isSpam': true,
      'confidence': 0.94,
      'time': 'Yesterday',
      'date': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _messages.where((m) {
      final matchFilter = _filter == 'All' ||
          (_filter == 'Spam' && m['isSpam'] == true) ||
          (_filter == 'Ham' && m['isSpam'] == false);
      final matchSearch = _searchQuery.isEmpty ||
          (m['sender'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (m['content'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Messages'),
        leading: const Icon(Icons.message, color: AppTheme.accent),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.accent, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Row(
                  children: ['All', 'Spam', 'Ham'].map((f) {
                    final isSelected = _filter == f;
                    final color = f == 'Spam'
                        ? AppTheme.spamRed
                        : f == 'Ham'
                            ? AppTheme.hamGreen
                            : AppTheme.accent;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.2)
                                : Colors.transparent,
                            border: Border.all(
                                color: isSelected
                                    ? color
                                    : AppTheme.textSecondary.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(f,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? color
                                    : AppTheme.textSecondary,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) => _MessageCard(
                message: filtered[i],
                onTap: () => _showDetailSheet(context, filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Map<String, dynamic> msg) {
    final isSpam = msg['isSpam'] as bool;
    final confidence = msg['confidence'] as double;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isSpam ? AppTheme.spamRed : AppTheme.hamGreen)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: (isSpam ? AppTheme.spamRed : AppTheme.hamGreen)
                            .withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isSpam ? '🚨 SPAM' : '✅ HAM',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSpam ? AppTheme.spamRed : AppTheme.hamGreen,
                    ),
                  ),
                ),
                const Spacer(),
                Text(msg['time'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            Text('From: ${msg['sender']}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                )),
            const SizedBox(height: 10),
            Text(msg['content'] as String,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                )),
            const SizedBox(height: 20),
            // Confidence bar
            Text('Confidence Score',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                )),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: AppTheme.card,
                valueColor: AlwaysStoppedAnimation<Color>(
                    isSpam ? AppTheme.spamRed : AppTheme.hamGreen),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}% ${isSpam ? 'Spam' : 'Ham'} probability',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.dangerous_outlined,
                        color: AppTheme.spamRed, size: 18),
                    label: Text('Mark as Spam',
                        style: GoogleFonts.inter(
                            color: AppTheme.spamRed, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppTheme.spamRed.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    label: Text('Mark as Safe',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.hamGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onTap;

  const _MessageCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSpam = message['isSpam'] as bool;
    final confidence = message['confidence'] as double;
    final color = isSpam ? AppTheme.spamRed : AppTheme.hamGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (message['sender'] as String)[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(message['sender'] as String,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      )),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSpam ? 'SPAM' : 'HAM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message['content'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: AppTheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
