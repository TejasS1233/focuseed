import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/session_state.dart';
import '../state/garden_state.dart';
import '../theme/theme.dart';
import 'session_setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final garden = ref.watch(gardenProvider);
    final session = ref.watch(sessionProvider);

    final aliveTrees = garden.trees.where((t) => t.isAlive).length;
    final totalTrees = garden.trees.length;

    return Scaffold(
      appBar: AppBar(title: Text('Focus Garden')),
      body: Padding(
        padding: const EdgeInsets.all(UISpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome${user != null ? ", $user" : ""}',
              style: UITypography.heading2),
            const SizedBox(height: UISpacing.md),
            Row(
              children: [
                _StatCard(
                  icon: Icons.timer,
                  label: 'Sessions',
                  value: '${session.status == SessionStatus.completed ? 1 : 0}',
                ),
                const SizedBox(width: UISpacing.sm),
                _StatCard(
                  icon: Icons.eco,
                  label: 'Trees',
                  value: '$aliveTrees/$totalTrees',
                ),
                const SizedBox(width: UISpacing.sm),
                _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '0',
                ),
              ],
            ),
            const SizedBox(height: UISpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SessionSetupScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.primary,
                  foregroundColor: UIColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text('Start Focus Session',
                  style: UITypography.heading3),
              ),
            ),
            const SizedBox(height: UISpacing.lg),
            Text('Your Garden', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            if (garden.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (garden.trees.isEmpty)
              Expanded(
                child: Center(
                  child: Text('Complete a session to plant your first tree!',
                    style: UITypography.body.copyWith(color: UIColors.gray500),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: garden.trees.length > 9 ? 9 : garden.trees.length,
                  itemBuilder: (_, i) {
                    final tree = garden.trees[i];
                    return _TreeTile(tree: tree);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(UISpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(UIRadius.md),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(height: 4),
            Text(value, style: UITypography.heading2),
            Text(label, style: UITypography.caption),
          ],
        ),
      ),
    );
  }
}

class _TreeTile extends StatelessWidget {
  final dynamic tree;

  const _TreeTile({required this.tree});

  @override
  Widget build(BuildContext context) {
    final stage = tree.growthStage;
    final alive = tree.isAlive;
    return Container(
      decoration: BoxDecoration(
        color: alive ? UIColors.gray50 : UIColors.gray200,
        borderRadius: BorderRadius.circular(UIRadius.md),
        border: Border.all(color: alive ? UIColors.gray200 : UIColors.gray300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            alive ? Icons.eco : Icons.error_outline,
            color: alive ? Colors.green : UIColors.gray500,
            size: 32,
          ),
          Text('Stage $stage',
            style: UITypography.caption),
        ],
      ),
    );
  }
}
