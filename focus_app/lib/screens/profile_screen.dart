import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/session_state.dart';
import '../theme/theme.dart';
import 'blacklist_screen.dart';
import 'journal_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeModeProvider);
    final session = ref.watch(sessionProvider);

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
              icon: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 18,
              ),
              color: context.textMuted,
              onPressed: () {
                ref.read(themeModeProvider.notifier).state = !isDark;
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppEffects.glassCard(radius: AppRadius.xl),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.4),
                    ),
                    child: Center(
                      child: Text(
                        user?.isNotEmpty == true ? user![0].toUpperCase() : '?',
                        style: AppTypography.display2.copyWith(
                          color: AppColors.black, fontSize: 28,
                        ),
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
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${session.elapsedSeconds ~/ 60} min focused',
                              style: AppTypography.body.copyWith(color: context.textMuted)),
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
                Expanded(child: _StatsTile(
                  icon: Icons.timer_outlined, label: 'Total Focus',
                  value: '${session.elapsedSeconds ~/ 60}m',
                  color: AppColors.primary,
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatsTile(
                  icon: Icons.check_circle_outlined, label: 'Sessions',
                  value: session.status == SessionStatus.completed ? '1' : '0',
                  color: AppColors.secondary,
                )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatsTile(
                  icon: Icons.local_fire_department_outlined, label: 'Streak',
                  value: '0',
                  color: AppColors.tertiary,
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatsTile(
                  icon: Icons.emoji_events_outlined, label: 'Best Streak',
                  value: '0',
                  color: AppColors.warning,
                )),
              ],
            ),
            const SizedBox(height: 28),
            Text('Achievements', style: AppTypography.heading1),
            const SizedBox(height: 12),
            Container(
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
                      child: Icon(Icons.book_outlined, color: AppColors.primary, size: 20),
                    ),
                    title: Text('Session Journal', style: AppTypography.heading3),
                    subtitle: Text('Reflections and session history',
                      style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.chevron_right, color: context.textMuted, size: 20),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const JournalScreen(),
                      ));
                    },
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
                    subtitle: Text('Manage distractions during hard lock',
                      style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.chevron_right, color: context.textMuted, size: 20),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const BlacklistScreen(),
                      ));
                    },
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

  const _StatsTile({
    required this.icon, required this.label, required this.value, required this.color,
  });

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
