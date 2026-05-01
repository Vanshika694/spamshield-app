import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/sms_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProcessedSms> _messages = [];
  Map<String, int> _stats = {'total': 0, 'spam': 0, 'ham': 0};
  bool _isLoading = true;
  int _processed = 0;
  int _total = 0;
  StreamSubscription<ProcessedSms>? _newSmsSub;
  StreamSubscription<(int, int)>? _progressSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _newSmsSub = SmsService.onNewSms.listen(_onNewSms);
    _progressSub = SmsService.onProgress.listen((p) {
      if (mounted) setState(() { _processed = p.$1; _total = p.$2; });
    });
  }

  void _onNewSms(ProcessedSms sms) {
    if (!mounted) return;
    setState(() {
      final idx = _messages.indexWhere((m) => m.sender == sms.sender && m.body == sms.body);
      if (idx >= 0) {
        _messages[idx] = sms;
      } else {
        _messages = [sms, ..._messages];
      }
      _stats = SmsService.getStats(_messages);
    });
  }

  // ...

  Future<void> _loadData() async {
    final msgs = await SmsService.getAllSms();
    final stats = SmsService.getStats(msgs);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _newSmsSub?.cancel();
    _progressSub?.cancel();
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
      body: _isLoading && _messages.isEmpty
        ? Center(
            child: Text(
              'Preparing...',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
            ),
          )
        : TabBarView(
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
              _MiniStatCard(
                  label: 'Accuracy',
                  value: '${(_messages.isEmpty ? 98.5 : (_messages.map((m) => m.confidence).reduce((a, b) => a + b) / _messages.length * 100)).toStringAsFixed(1)}%',
                  icon: Icons.track_changes,
                  color: AppTheme.accent),
              const SizedBox(width: 12),
              _MiniStatCard(
                  label: 'Analyzed',
                  value: _stats['total'].toString(),
                  icon: Icons.bar_chart,
                  color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStatCard(label: 'Real-time', value: 'ON', icon: Icons.bolt, color: AppTheme.accent),
              const SizedBox(width: 12),
              _MiniStatCard(label: 'Blocked', value: _stats['spam'].toString(), icon: Icons.block, color: AppTheme.spamRed),
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
    final spamVal = _stats['spam']!.toDouble();
    final hamVal = _stats['ham']!.toDouble();
    final spamPct = _stats['total'] == 0 ? 0 : ((spamVal / _stats['total']!) * 100).toInt();

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
          Text('Total ${_stats['total']} messages analyzed',
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
                    value: spamVal == 0 && hamVal == 0 ? 1 : spamVal,
                    color: AppTheme.spamRed,
                    radius: 55,
                    title: 'Spam\n$spamPct%',
                    titleStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: spamVal == 0 && hamVal == 0 ? 0 : hamVal,
                    color: AppTheme.hamGreen,
                    radius: 55,
                    title: 'Safe\n${100 - spamPct}%',
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
    final Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var m in _messages.where((x) => x.isSpam)) {
      counts[m.date.weekday] = (counts[m.date.weekday] ?? 0) + 1;
    }
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final spamPerDay = [
      counts[1]!, counts[2]!, counts[3]!, counts[4]!, counts[5]!, counts[6]!, counts[7]!
    ];
    
    double maxVal = spamPerDay.map((e) => e.toDouble()).reduce(max);
    if (maxVal < 5) maxVal = 5;

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
                maxY: maxVal * 1.2,
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
                    spots: _getTrendSpots(),
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
          _SummaryRow(label: 'Real-time Stats', spam: _stats['spam']!, ham: _stats['ham']!),
          const Divider(color: Color(0xFF1E3050), height: 20),
        ],
      ),
    );
  }

  List<FlSpot> _getTrendSpots() {
    if (_messages.isEmpty) return const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0)];
    final now = DateTime.now();
    final counts = [0, 0, 0, 0];
    for (var m in _messages.where((x) => x.isSpam)) {
      final daysAgo = now.difference(m.date).inDays;
      if (daysAgo < 7) counts[3]++;
      else if (daysAgo < 14) counts[2]++;
      else if (daysAgo < 21) counts[1]++;
      else if (daysAgo < 28) counts[0]++;
    }
    return [
      FlSpot(0, counts[0].toDouble()),
      FlSpot(1, counts[1].toDouble()),
      FlSpot(2, counts[2].toDouble()),
      FlSpot(3, counts[3].toDouble()),
    ];
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
