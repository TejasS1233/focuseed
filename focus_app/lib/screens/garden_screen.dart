import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../widgets/shimmer.dart';
import '../widgets/tree_painter.dart';
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
      appBar: AppBar(
        title: Text('My Garden', style: AppTypography.display2.copyWith(fontSize: 24)),
      ),
      body: garden.isLoading
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                children: [
                  SkeletonCard(),
                  const SizedBox(height: 12),
                  SkeletonCard(),
                  const SizedBox(height: 12),
                  SkeletonCard(),
                ],
              ),
            )
          : garden.trees.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: const LivingTree(
                            species: 'sprout',
                            growthStage: 0,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Your garden is empty', style: AppTypography.display2),
                        const SizedBox(height: 8),
                        Text('Complete focus sessions to plant trees',
                          style: AppTypography.body.copyWith(color: context.textMuted)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = ref.read(userProvider);
                    if (user != null) {
                      await ref.read(gardenProvider.notifier).loadTrees(user);
                    }
                  },
                  color: AppColors.primary,
                  backgroundColor: context.surfaceElevated,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: garden.trees.length,
                      itemBuilder: (_, i) => _GardenTreeTile(
                        tree: garden.trees[i],
                        index: i,
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _GardenTreeTile extends StatefulWidget {
  final dynamic tree;
  final int index;

  const _GardenTreeTile({required this.tree, required this.index});

  @override
  State<_GardenTreeTile> createState() => _GardenTreeTileState();
}

class _GardenTreeTileState extends State<_GardenTreeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late AnimationController _deathController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _animController.forward();
    });

    _deathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!widget.tree.isAlive) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _deathController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _deathController.dispose();
    super.dispose();
  }

  Color _color() {
    if (!widget.tree.isAlive) return context.textMuted;
    switch (widget.tree.species) {
      case 'oak': return const Color(0xFF00CC6A);
      case 'pine': return const Color(0xFF3B82F6);
      case 'cherry': return const Color(0xFFFF4D6D);
      default: return AppColors.primary;
    }
  }

  String _title() {
    switch (widget.tree.species) {
      case 'oak': return 'Oak';
      case 'pine': return 'Pine';
      case 'cherry': return 'Cherry';
      default: return 'Sprout';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    final alive = widget.tree.isAlive;

    return FadeTransition(
      opacity: _opacityAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedBuilder(
          animation: _deathController,
          builder: (context, _) {
            final deathProgress = _deathController.value;
            final tileOpacity = alive ? 1.0 : (1.0 - deathProgress * 0.3);

            return Opacity(
              opacity: tileOpacity,
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceElevated.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: alive
                        ? c.withOpacity(0.2)
                        : Color.lerp(c, context.border, deathProgress)!.withOpacity(0.3),
                    width: 0.5,
                  ),
                  boxShadow: alive
                      ? [
                          BoxShadow(
                            color: c.withOpacity(0.06),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LivingTree(
                      species: widget.tree.species,
                      growthStage: widget.tree.growthStage,
                      isAlive: alive,
                      size: 72,
                      entryProgress: _animController.value,
                      deathProgress: deathProgress,
                    ),
                    const SizedBox(height: 8),
                    Text(_title(), style: AppTypography.heading3.copyWith(
                      color: alive ? context.textPrimary : context.textMuted,
                    )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: alive
                            ? c.withOpacity(0.12)
                            : context.border.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        alive ? 'Stage ${widget.tree.growthStage}' : 'Wilted',
                        style: AppTypography.caption.copyWith(
                          color: alive ? c : context.textMuted,
                        ),
                      ),
                    ),
                    if (alive && widget.tree.growthStage >= 3) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 12, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text('Mature', style: AppTypography.caption.copyWith(
                            color: AppColors.secondary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
