import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/session_state.dart';
import '../theme/theme.dart';
import 'blacklist_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeModeProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 18,
                color: UIColors.gray500,
              ),
              Switch(
                value: isDark,
                onChanged: (v) {
                  ref.read(themeModeProvider.notifier).state = v;
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UISpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: UIColors.primary,
                  child: Text(
                    user?.isNotEmpty == true
                        ? user![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: UISpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user ?? 'Focus Gardener',
                      style: UITypography.heading2),
                    Text('${session.elapsedSeconds ~/ 60} min focused',
                      style: UITypography.body.copyWith(
                        color: UIColors.gray500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: UISpacing.xl),
            Text('Stats', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            Row(
              children: [
                Expanded(child: _StatsTile(
                  icon: Icons.timer, label: 'Total Focus',
                  value: '${session.elapsedSeconds ~/ 60}m',
                )),
                const SizedBox(width: 8),
                Expanded(child: _StatsTile(
                  icon: Icons.check_circle, label: 'Sessions',
                  value: session.status == SessionStatus.completed ? '1' : '0',
                )),
              ],
            ),
            const SizedBox(height: UISpacing.sm),
            Row(
              children: [
                Expanded(child: _StatsTile(
                  icon: Icons.local_fire_department, label: 'Streak',
                  value: '0',
                )),
                const SizedBox(width: 8),
                Expanded(child: _StatsTile(
                  icon: Icons.emoji_events, label: 'Best Streak',
                  value: '0',
                )),
              ],
            ),
            const SizedBox(height: UISpacing.xl),
            Text('Achievements', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            Expanded(
              child: Center(
                child: Text('Complete focus sessions to unlock achievements',
                  style: UITypography.body.copyWith(color: UIColors.gray500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blocked Apps'),
              subtitle: const Text('Choose apps to block during hard lock'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const BlacklistScreen(),
                ));
              },
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

  const _StatsTile({
    required this.icon, required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(UISpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(UIRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: UITypography.heading3),
          Text(label, style: UITypography.caption),
        ],
      ),
    );
  }
}
