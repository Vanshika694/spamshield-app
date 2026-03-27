import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'classification_screen.dart';
import 'analytics_screen.dart';
import 'admin_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    ClassificationScreen(),
    AnalyticsScreen(),
    AdminScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 20), activeIcon: Icon(Icons.grid_view_rounded, size: 20), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded, size: 20), activeIcon: Icon(Icons.chat_bubble_rounded, size: 20), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded, size: 20), activeIcon: Icon(Icons.bar_chart_rounded, size: 20), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_outlined, size: 20), activeIcon: Icon(Icons.shield_rounded, size: 20), label: 'Admin'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 20), activeIcon: Icon(Icons.person_rounded, size: 20), label: 'Account'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REDESIGNED DASHBOARD TAB
// ─────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (mounted) setState(() => _userName = user.name);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildSecurityStatusCard(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildChartCard(),
                const SizedBox(height: 20),
                _buildWeeklyTrendCard(),
                const SizedBox(height: 20),
                _buildRecentMessages(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: AppTheme.surface,
      floating: true,
      pinned: false,
      elevation: 0,
      toolbarHeight: 64,
      title: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.security, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SpamShield',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text('Security Suite',
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
      actions: [
        // Notification bell
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                onPressed: () {},
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppTheme.spamRed, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStatusCard() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                const Color(0xFF0F172A),
                const Color(0xFF1E293B),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.2 + 0.1 * _pulseCtrl.value),
            ),
          ),
          child: Row(
            children: [
              // Shield
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.hamGreen.withValues(
                          alpha: 0.08 + 0.06 * _pulseCtrl.value),
                    ),
                  ),
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.hamGreen.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppTheme.hamGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.verified_user_rounded,
                        color: AppTheme.hamGreen, size: 26),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.hamGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.hamGreen.withValues(alpha: 0.35)),
                          ),
                          child: Row(children: [
                            Container(width: 5, height: 5,
                                decoration: const BoxDecoration(
                                    color: AppTheme.hamGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text('PROTECTED',
                                style: GoogleFonts.inter(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: AppTheme.hamGreen, letterSpacing: 0.8)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Good morning, $_userName',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text('Your device is secure',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              // Security score
              Column(
                children: [
                  Text('92',
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.accent)),
                  Text('/ 100',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                  Text('SCORE',
                      style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted, letterSpacing: 1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(label: 'Total SMS', count: '248', icon: Icons.chat_bubble_outline_rounded, color: AppTheme.accent, sub: '+12 today'),
        const SizedBox(width: 10),
        _StatCard(label: 'Spam', count: '47', icon: Icons.dangerous_outlined, color: AppTheme.spamRed, sub: '18.9%'),
        const SizedBox(width: 10),
        _StatCard(label: 'Safe', count: '201', icon: Icons.check_circle_outline_rounded, color: AppTheme.hamGreen, sub: '81.1%'),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Detection Overview', subtitle: '248 messages analysed'),
          const SizedBox(height: 18),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 38,
                      sections: [
                        PieChartSectionData(value: 47, color: AppTheme.spamRed, radius: 32, showTitle: false),
                        PieChartSectionData(value: 201, color: AppTheme.hamGreen, radius: 32, showTitle: false),
                      ],
                    )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('19%',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.spamRed)),
                        Text('spam',
                            style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(color: AppTheme.hamGreen, label: 'Safe messages', value: '201', pct: '81%'),
                    const SizedBox(height: 16),
                    _LegendRow(color: AppTheme.spamRed, label: 'Spam detected', value: '47', pct: '19%'),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
                      ),
                      child: Text('⚡ 40% less spam\nthan last week',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.accent, height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendCard() {
    final data = [4.0, 7.0, 2.0, 9.0, 5.0, 11.0, 7.0];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Weekly Spam Trend', subtitle: 'Spam messages per day'),
          const SizedBox(height: 18),
          SizedBox(
            height: 100,
            child: BarChart(BarChartData(
              maxY: 14,
              barTouchData: BarTouchData(enabled: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border.withValues(alpha: 0.4), strokeWidth: 0.8),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) => Text(days[v.toInt()],
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                )),
              ),
              barGroups: List.generate(data.length, (i) => BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(
                  toY: data[i],
                  width: 18,
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [AppTheme.spamRed.withValues(alpha: 0.7), AppTheme.spamRed],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )],
              )),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMessages() {
    final msgs = [
      {'s': '+91 98765 43210', 'p': "Congratulations! You've won ₹50,000. Click now!", 'spam': true,  't': '9:23 AM'},
      {'s': 'Mom',             'p': 'Are you coming home for dinner tonight?',          'spam': false, 't': '8:45 AM'},
      {'s': 'HDFC Bank',       'p': 'Your account credited with ₹5,000 on 11/03/26.',  'spam': false, 't': '7:30 AM'},
      {'s': '+1 800 FREE',     'p': 'URGENT: Claim your FREE iPhone 15 now!',           'spam': true,  't': '6:15 AM'},
    ];

    return Container(
      decoration: AppTheme.glassCard(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text('Recent Messages',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const Spacer(),
                Text('View all',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accent)),
              ],
            ),
          ),
          ...msgs.asMap().entries.map((e) {
            final m = e.value;
            final isLast = e.key == msgs.length - 1;
            return _MsgTile(
              sender: m['s'] as String,
              preview: m['p'] as String,
              isSpam: m['spam'] as bool,
              time: m['t'] as String,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ───────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      const SizedBox(height: 2),
      Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String label, count, sub;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.count, required this.icon, required this.color, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(height: 10),
            Text(count, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 1),
            Text(sub, style: GoogleFonts.inter(fontSize: 9, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label, value, pct;
  const _LegendRow({required this.color, required this.label, required this.value, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary))),
        Text(pct, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _MsgTile extends StatelessWidget {
  final String sender, preview, time;
  final bool isSpam, isLast;

  const _MsgTile({required this.sender, required this.preview, required this.isSpam, required this.time, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = isSpam ? AppTheme.spamRed : AppTheme.hamGreen;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(sender[0].toUpperCase(),
                      style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(sender,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                        Text(time, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isSpam ? 'SPAM' : 'HAM',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppTheme.border.withValues(alpha: 0.4), indent: 63, endIndent: 14),
      ],
    );
  }
}
