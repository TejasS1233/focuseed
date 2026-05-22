import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _totalSeconds = 0;
  int _totalSessions = 0;
  int _streak = 0;
  Map<String, int>? _dailyTotals;
  Map<String, int>? _monthlyTotals;
  Map<String, int>? _tagSeconds;
  List<Session>? _recent;
  List<String> _availableTags = [];
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = ref.read(userProvider);
    if (userId == null) return;
    final dao = SessionDao(ref.read(databaseProvider));

    if (_selectedTag != null) {
      final tagged = await dao.getSessionsByTag(userId, _selectedTag!);
      final completed = tagged.where((s) => s.outcome == 'completed').toList();
      setState(() {
        _totalSeconds = tagged.fold<int>(0, (s, e) => s + e.durationSeconds);
        _totalSessions = completed.length;
        _recent = tagged.take(10).toList();
      });
      final range = DateTime.now().subtract(const Duration(days: 30));
      dao.getDailyTotals(userId, range, DateTime.now()).then((d) { if (mounted) _parseMonthlyTotals(d); });
    } else {
      final sessions = await dao.getSessionsByUser(userId);
      final completed = sessions.where((s) => s.outcome == 'completed').toList();
      setState(() {
        _totalSeconds = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
        _totalSessions = completed.length;
      });
      dao.getSessionsInRange(userId, DateTime.now().subtract(const Duration(days: 30)), DateTime.now())
          .then((r) { if (mounted) setState(() => _recent = r.take(10).toList()); });
    }

    dao.getCurrentStreak(userId).then((s) { if (mounted) setState(() => _streak = s); });
    dao.getDistinctTags(userId).then((t) { if (mounted) setState(() => _availableTags = t); });
    dao.getDailyTotals(userId, DateTime.now().subtract(const Duration(days: 7)), DateTime.now())
        .then((d) { if (mounted) _parseDailyTotals(d); });
    dao.getDailyTotals(userId, DateTime.now().subtract(const Duration(days: 30)), DateTime.now())
        .then((d) { if (mounted) _parseMonthlyTotals(d); });
    dao.getTaggedSeconds(userId, DateTime.now().subtract(const Duration(days: 30)), DateTime.now())
        .then((d) { if (mounted) setState(() => _tagSeconds = d); });
  }

  void _parseDailyTotals(List<Map<String, dynamic>> raw) {
    final map = <String, int>{};
    for (final r in raw) {
      map[r['day'] as String] = r['total'] as int;
    }
    if (mounted) setState(() => _dailyTotals = map);
  }

  void _parseMonthlyTotals(List<Map<String, dynamic>> raw) {
    final map = <String, int>{};
    for (final r in raw) {
      map[r['day'] as String] = r['total'] as int;
    }
    if (mounted) setState(() => _monthlyTotals = map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: AppTypography.display2.copyWith(fontSize: 24)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            if (_availableTags.isNotEmpty) ...[
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [null, ..._availableTags].map((t) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedTag = t);
                    _load();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedTag == t
                          ? AppColors.primary.withOpacity(0.15)
                          : context.surfaceElevated.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: _selectedTag == t ? AppColors.primary.withOpacity(0.4) : context.border,
                        width: 0.5,
                      ),
                    ),
                    child: Text(t ?? 'All', style: AppTypography.label.copyWith(
                      color: _selectedTag == t ? AppColors.primary : context.textMuted,
                      fontSize: 11,
                    )),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            _StatGrid(totalSeconds: _totalSeconds, totalSessions: _totalSessions, streak: _streak),
            const SizedBox(height: 28),
            if (_dailyTotals != null) ...[
              Text('This Week', style: AppTypography.heading1),
              const SizedBox(height: 12),
              _WeekChart(dailyTotals: _dailyTotals!),
            ],
            if (_monthlyTotals != null) ...[
              const SizedBox(height: 28),
              Text('Monthly Trend', style: AppTypography.heading1),
              const SizedBox(height: 12),
              _MonthlyChart(dailyTotals: _monthlyTotals!),
            ],
            if (_tagSeconds != null && _tagSeconds!.isNotEmpty && _availableTags.length >= 2) ...[
              const SizedBox(height: 28),
              Text('By Tag', style: AppTypography.heading1),
              const SizedBox(height: 12),
              _TagChart(tagSeconds: _tagSeconds!),
            ],
            if (_recent != null && _recent!.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Recent Sessions', style: AppTypography.heading1),
              const SizedBox(height: 12),
              ...(_recent!.map((s) => _SessionRow(session: s))),
            ],
            if (_recent != null && _recent!.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('Complete a session to see analytics', style: AppTypography.body.copyWith(color: context.textMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final int totalSeconds, totalSessions, streak;

  const _StatGrid({required this.totalSeconds, required this.totalSessions, required this.streak});

  @override
  Widget build(BuildContext context) {
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.timer_outlined, label: 'Total Focus', value: timeStr, color: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(icon: Icons.check_circle_outlined, label: 'Sessions', value: '$totalSessions', color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.local_fire_department, label: 'Streak', value: '${streak}d', color: AppColors.tertiary)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(icon: Icons.emoji_events_outlined, label: 'Best', value: '${streak}d', color: AppColors.warning)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.12), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.heading1.copyWith(fontSize: 20, color: context.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: context.textMuted)),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final Map<String, int> dailyTotals;

  const _WeekChart({required this.dailyTotals});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _dayName(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length != 3) return '';
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return _dayLabels[dt.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final isDark = context.isDark;

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
      ),
      child: entries.isEmpty
          ? Center(child: Text('No data this week', style: AppTypography.body.copyWith(color: context.textMuted)))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() * 1.15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (_, __, ___, ____) => null,
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.border.withOpacity(0.15),
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _dayName(entries[i].key),
                            style: TextStyle(
                              color: isDark ? AppColors.textMuted : AppColorsLight.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  final pct = entry.value > 0 ? 1.0 : 0.3;
                  final color = isDark ? AppColors.primary : AppColors.primaryDark;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: color.withOpacity(pct),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final Map<String, int> dailyTotals;

  const _MonthlyChart({required this.dailyTotals});

  @override
  Widget build(BuildContext context) {
    final entries = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final isDark = context.isDark;

    if (entries.isEmpty) {
      return Container(
        height: 190,
        decoration: BoxDecoration(
          color: context.surfaceElevated.withOpacity(0.25),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
        ),
        child: Center(child: Text('No monthly data yet', style: AppTypography.body.copyWith(color: context.textMuted))),
      );
    }

    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    String formatDate(String dateKey) {
      final parts = dateKey.split('-');
      if (parts.length != 3) return '';
      return '${parts[1]}/${parts[2]}';
    }

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.border.withOpacity(0.15),
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: (entries.length / 6).ceilToDouble().clamp(1, 5),
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      formatDate(entries[i].key),
                      style: TextStyle(
                        color: isDark ? AppColors.textMuted : AppColorsLight.textMuted,
                        fontSize: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final i = spot.spotIndex;
                final secs = entries[i].value;
                final mins = (secs / 60).round();
                return LineTooltipItem(
                  '${mins}m',
                  TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary, fontSize: 11),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble())).toList(),
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 2.5,
                  color: AppColors.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChart extends StatelessWidget {
  final Map<String, int> tagSeconds;

  const _TagChart({required this.tagSeconds});

  static const _colors = [
    AppColors.primary,
    AppColors.tertiary,
    AppColors.secondary,
    AppColors.error,
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    final total = tagSeconds.values.fold<int>(0, (a, b) => a + b);
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 1,
                centerSpaceRadius: 28,
                sections: tagSeconds.entries.toList().asMap().entries.map((e) {
                  final i = e.key;
                  final seconds = e.value.value;
                  final pct = total > 0 ? seconds / total : 0.0;
                  return PieChartSectionData(
                    value: pct * 100,
                    color: _colors[i % _colors.length],
                    radius: i == 0 ? 28 : 24,
                    title: '${(pct * 100).round()}%',
                    titleStyle: TextStyle(
                      color: isDark ? AppColors.surface : AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: tagSeconds.entries.toList().asMap().entries.map((e) {
                final i = e.key;
                final tag = e.value.key;
                final seconds = e.value.value;
                final mins = (seconds / 60).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(tag, style: AppTypography.caption.copyWith(color: context.textPrimary)),
                      ),
                      Text('${mins}m', style: AppTypography.caption.copyWith(color: context.textMuted)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final Session session;

  const _SessionRow({required this.session});

  String _formatDuration(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = session.outcome == 'completed';
    final color = isComplete ? AppColors.primary : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.border.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(isComplete ? Icons.check_circle : Icons.cancel, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.mode.toUpperCase(), style: AppTypography.caption.copyWith(color: context.textMuted)),
                if (session.intention != null)
                  Text(session.intention!, style: AppTypography.bodySmall.copyWith(color: context.textPrimary)),
              ],
            ),
          ),
          Text(_formatDuration(session.durationSeconds), style: AppTypography.bodySmall.copyWith(color: context.textPrimary)),
        ],
      ),
    );
  }
}
