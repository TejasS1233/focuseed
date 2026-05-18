import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/garden_state.dart';
import '../theme/theme.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Garden')),
      body: garden.isLoading
          ? const Center(child: CircularProgressIndicator())
          : garden.trees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 80, color: UIColors.gray300),
                      const SizedBox(height: UISpacing.md),
                      Text('Your garden is empty',
                        style: UITypography.heading3),
                      Text('Complete focus sessions to plant trees',
                        style: UITypography.body.copyWith(
                          color: UIColors.gray500)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(UISpacing.md),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: garden.trees.length,
                    itemBuilder: (_, i) => _GardenTreeTile(
                      tree: garden.trees[i],
                    ),
                  ),
                ),
    );
  }
}

class _GardenTreeTile extends StatelessWidget {
  final dynamic tree;

  const _GardenTreeTile({required this.tree});

  IconData _icon() {
    if (!tree.isAlive) return Icons.error_outline;
    switch (tree.species) {
      case 'oak': return Icons.eco;
      case 'pine': return Icons.eco;
      case 'cherry': return Icons.local_florist;
      default: return Icons.eco;
    }
  }

  Color _color() {
    if (!tree.isAlive) return UIColors.gray400;
    switch (tree.species) {
      case 'oak': return const Color(0xFF2E7D32);
      case 'pine': return const Color(0xFF1565C0);
      case 'cherry': return const Color(0xFFE91E63);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: tree.isAlive ? cs.surface : cs.surfaceVariant,
        borderRadius: BorderRadius.circular(UIRadius.md),
        border: Border.all(
          color: tree.isAlive ? cs.outlineVariant : cs.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon(), color: _color(), size: 36),
          const SizedBox(height: 4),
          Text(tree.species, style: UITypography.caption),
          if (tree.isAlive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Stage ${tree.growthStage}',
                style: const TextStyle(fontSize: 10, color: Colors.green)),
            )
          else
            Text('Wilted',
              style: UITypography.caption.copyWith(color: UIColors.gray500)),
        ],
      ),
    );
  }
}
