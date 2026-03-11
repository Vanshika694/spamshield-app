import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.analytics, color: AppTheme.accent),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 13),
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats summary row
          Row(
            children: [
              _MiniStatCard(label: 'Accuracy', value: '96.4%', icon: Icons.track_changes, color: AppTheme.accent),
              const SizedBox(width: 12),
              _MiniStatCard(label: 'Analyzed', value: '248', icon: Icons.bar_chart, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStatCard(label: 'Spam Rate', value: '18.9%', icon: Icons.dangerous_outlined, color: AppTheme.spamRed),
              const SizedBox(width: 12),
              _MiniStatCard(label: 'Blocked', value: '47', icon: Icons.block, color: AppTheme.hamGreen),
            ],
          ),
          const SizedBox(height: 20),
          // Pie chart card
          _buildPieCard(),
          const SizedBox(height: 20),
          // Bar chart card
          _buildBarCard(),
        ],
      ),
    );
  }

  Widget _buildPieCard() {
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
          Text('Spam vs Ham',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('Total 248 messages analyzed',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 42,
                sections: [
                  PieChartSectionData(
                    value: 47,
                    color: AppTheme.spamRed,
                    radius: 55,
                    title: 'Spam\n19%',
                    titleStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 201,
                    color: AppTheme.hamGreen,
                    radius: 55,
                    title: 'Ham\n81%',
                    titleStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard() {
    final spamPerDay = [4, 7, 2, 9, 5, 11, 9];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = 14.0;

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
          Text('Spam per Day',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('This week\'s spam count',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[value.toInt()],
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  spamPerDay.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: spamPerDay[i].toDouble(),
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.spamRed.withValues(alpha: 0.6),
                            AppTheme.spamRed,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildLineChartCard(),
          const SizedBox(height: 20),
          _buildWeeklyComparison(),
        ],
      ),
    );
  }

  Widget _buildLineChartCard() {
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
          Text('Spam Growth Trend',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('Last 4 weeks',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['W1', 'W2', 'W3', 'W4'];
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[value.toInt()],
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 3,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 28),
                      FlSpot(1, 35),
                      FlSpot(2, 30),
                      FlSpot(3, 47),
                    ],
                    isCurved: true,
                    color: AppTheme.spamRed,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.spamRed,
                        strokeWidth: 2,
                        strokeColor: AppTheme.bg,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.spamRed.withValues(alpha: 0.3),
                          AppTheme.spamRed.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Summary',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          _SummaryRow(label: 'This week', spam: 47, ham: 201),
          const Divider(color: Color(0xFF1E3050), height: 20),
          _SummaryRow(label: 'Last week', spam: 65, ham: 183),
          const Divider(color: Color(0xFF1E3050), height: 20),
          Row(
            children: [
              const Icon(Icons.trending_down, color: AppTheme.hamGreen, size: 18),
              const SizedBox(width: 8),
              Text('27.7% fewer spam messages than last week!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.hamGreen,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    )),
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int spam;
  final int ham;

  const _SummaryRow({required this.label, required this.spam, required this.ham});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              )),
        ),
        _Badge(value: '$spam spam', color: AppTheme.spamRed),
        const SizedBox(width: 8),
        _Badge(value: '$ham ham', color: AppTheme.hamGreen),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String value;
  final Color color;

  const _Badge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(value,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}
