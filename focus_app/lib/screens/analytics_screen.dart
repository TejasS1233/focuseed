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
      dao.getDailyTotals(userId, range, DateTime.now()).then((d) => _parseDailyTotals(d));
    } else {
      final sessions = await dao.getSessionsByUser(userId);
      final completed = sessions.where((s) => s.outcome == 'completed').toList();
      setState(() {
        _totalSeconds = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
        _totalSessions = completed.length;
      });
      dao.getSessionsInRange(userId, DateTime.now().subtract(const Duration(days: 30)), DateTime.now())
          .then((r) => setState(() => _recent = r.take(10).toList()));
    }

    dao.getCurrentStreak(userId).then((s) => setState(() => _streak = s));
    dao.getDistinctTags(userId).then((t) => setState(() => _availableTags = t));
    dao.getDailyTotals(userId, DateTime.now().subtract(const Duration(days: 7)), DateTime.now())
        .then((d) => _parseDailyTotals(d));
  }

  void _parseDailyTotals(List<Map<String, dynamic>> raw) {
    final map = <String, int>{};
    for (final r in raw) {
      map[r['day'] as String] = r['total'] as int;
    }
    setState(() => _dailyTotals = map);
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

  @override
  Widget build(BuildContext context) {
    final entries = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('No data this week', style: AppTypography.body.copyWith(color: context.textMuted))),
      );
    }
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(entries: entries, maxVal: maxVal, isDark: context.isDark),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final double maxVal;
  final bool isDark;

  _BarChartPainter({required this.entries, required this.maxVal, required this.isDark});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _dayName(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return '';
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    return _dayLabels[dt.weekday - 1];
  }

  String _minutes(int seconds) => '${(seconds / 60).round()}m';

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final barWidth = (size.width - 20) / entries.length * 0.6;
    final gap = (size.width - 20) / entries.length;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? AppColors.primary : AppColors.primaryDark;

    final mutedPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? AppColors.primary : AppColors.primaryDark).withOpacity(0.15);

    final textStyle = TextStyle(
      color: isDark ? AppColors.textMuted : AppColorsLight.textMuted,
      fontSize: 9,
      fontFamily: AppTypography.bodyFont,
    );

    for (int i = 0; i < entries.length; i++) {
      final x = 10 + i * gap + (gap - barWidth) / 2;
      final barH = maxVal > 0 ? (entries[i].value / maxVal) * (size.height - 40) : 0.0;
      final barTop = size.height - 20 - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, barTop, barWidth, barH), const Radius.circular(3)),
        barH > 0 ? paint : mutedPaint,
      );

      final label = _dayName(entries[i].key);
      final tp = TextPainter(text: TextSpan(text: label, style: textStyle), textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, size.height - 16));

      if (barH > 0 && entries[i].value >= 60) {
        final valTp = TextPainter(
          text: TextSpan(text: _minutes(entries[i].value), style: textStyle.copyWith(fontSize: 8, color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(canvas, Offset(x + (barWidth - valTp.width) / 2, barTop - 14));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => old.entries != entries;
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
