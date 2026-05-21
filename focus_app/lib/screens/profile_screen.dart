import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import '../core/db/daos/achievement_dao.dart';
import '../core/services/widget_service.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import 'analytics_screen.dart';
import 'blacklist_screen.dart';
import 'journal_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Achievement>? _achievements;
  int _totalSeconds = 0;
  int _completedCount = 0;
  int _streak = 0;
  int _dailyGoalMinutes = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = ref.read(userProvider);
    if (userId == null) return;

    final db = ref.read(databaseProvider);
    final sessionDao = SessionDao(db);
    final achievementDao = AchievementDao(db);

    final sessions = await sessionDao.getSessionsByUser(userId);
    final completed = sessions.where((s) => s.outcome == 'completed').toList();

    setState(() {
      _totalSeconds = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
      _completedCount = completed.length;
    });

    db.getDailyGoal(userId).then((g) => setState(() => _dailyGoalMinutes = g));
    sessionDao.getCurrentStreak(userId).then((s) => setState(() => _streak = s));
    achievementDao.getAchievementsByUser(userId)
        .then((a) => setState(() => _achievements = a));
  }

  Future<void> _setGoal(int minutes) async {
    final userId = ref.read(userProvider);
    if (userId == null) return;
    final db = ref.read(databaseProvider);
    await db.setDailyGoal(userId, minutes);
    setState(() => _dailyGoalMinutes = minutes);

    final dao = SessionDao(db);
    final streak = await dao.getCurrentStreak(userId);
    final todaySeconds = await dao.getTodaySeconds(userId);
    await WidgetService.updateWidget(streak: streak, todayMinutes: todaySeconds ~/ 60);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeModeProvider);
    final hours = _totalSeconds ~/ 3600;
    final mins = (_totalSeconds % 3600) ~/ 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.display2.copyWith(fontSize: 24)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: context.surfaceElevated.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: context.border, width: 0.5),
            ),
            child: IconButton(
              icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 18),
              color: context.textMuted,
              onPressed: () => ref.read(themeModeProvider.notifier).state = !isDark,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppEffects.glassCard(radius: AppRadius.xl),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.4),
                    ),
                    child: Center(
                      child: Text(
                        user?.isNotEmpty == true ? user![0].toUpperCase() : '?',
                        style: AppTypography.display2.copyWith(color: AppColors.black, fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user ?? 'Focus Gardener', style: AppTypography.heading1),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('$_streak day streak', style: AppTypography.body.copyWith(color: context.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Statistics', style: AppTypography.heading1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatsTile(icon: Icons.timer_outlined, label: 'Total Focus', value: timeStr, color: AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: _StatsTile(icon: Icons.check_circle_outlined, label: 'Sessions', value: '$_completedCount', color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatsTile(icon: Icons.local_fire_department_outlined, label: 'Streak', value: '${_streak}d', color: AppColors.tertiary)),
                const SizedBox(width: 10),
                Expanded(child: _StatsTile(icon: Icons.emoji_events_outlined, label: 'Best', value: '${_streak}d', color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 28),
            Text('Daily Goal', style: AppTypography.heading1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceElevated.withOpacity(0.25),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_dailyGoalMinutes min/day', style: AppTypography.heading2),
                      Text('${_dailyGoalMinutes ~/ 60}h ${_dailyGoalMinutes % 60}m', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: context.surfaceHighlight,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _dailyGoalMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '$_dailyGoalMinutes min',
                      onChanged: (v) => setState(() => _dailyGoalMinutes = v.round()),
                      onChangeEnd: (v) => _setGoal(v.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [15, 30, 60, 120].map((m) => GestureDetector(
                      onTap: () => _setGoal(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _dailyGoalMinutes == m ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: _dailyGoalMinutes == m ? AppColors.primary.withOpacity(0.4) : context.border.withOpacity(0.3),
                          ),
                        ),
                        child: Text('${m}m', style: AppTypography.caption.copyWith(
                          color: _dailyGoalMinutes == m ? AppColors.primary : context.textMuted,
                        )),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Achievements (${_achievements?.length ?? 0}/9)', style: AppTypography.heading1),
            const SizedBox(height: 12),
            _achievements == null || _achievements!.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: AppEffects.glass(radius: AppRadius.lg),
                    child: Column(
                      children: [
                        Text('🏆', style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text('No achievements yet', style: AppTypography.heading2),
                        const SizedBox(height: 4),
                        Text('Complete focus sessions to unlock achievements',
                          style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _achievements!.map((a) => _AchievementChip(achievementKey: a.key, title: a.title, description: a.description)).toList(),
                  ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceElevated.withOpacity(0.25),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.border, width: 0.5),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.insights, color: AppColors.primary, size: 20),
                    ),
                    title: Text('Analytics', style: AppTypography.heading3),
                    subtitle: Text('Charts and insights', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: context.border.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(Icons.chevron_right, color: context.textMuted, size: 20),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                  ),
                  const Divider(height: 1, indent: 60, color: AppColorsLight.border),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.book_outlined, color: AppColors.secondary, size: 20),
                    ),
                    title: Text('Session Journal', style: AppTypography.heading3),
                    subtitle: Text('Reflections and session history', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: context.border.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(Icons.chevron_right, color: context.textMuted, size: 20),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
                  ),
                  const Divider(height: 1, indent: 60, color: AppColorsLight.border),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.block, color: AppColors.error, size: 20),
                    ),
                    title: Text('Blocked Apps', style: AppTypography.heading3),
                    subtitle: Text('Manage distractions during hard lock', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: context.border.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(Icons.chevron_right, color: context.textMuted, size: 20),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlacklistScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatsTile({required this.icon, required this.label, required this.value, required this.color});

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
          Text(value, style: AppTypography.heading1.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: context.textMuted)),
        ],
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final String achievementKey, title, description;
  const _AchievementChip({required this.achievementKey, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏆', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(title, style: AppTypography.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
