import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/daos/session_dao.dart';
import '../state/app_state.dart';
import '../state/session_state.dart';
import '../state/garden_state.dart';
import '../theme/theme.dart';
import 'session_setup_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _dailyGoalMinutes = 60;
  int _todayMinutes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDailyGoal();
    });
  }

  Future<void> _loadDailyGoal() async {
    final userId = ref.read(userProvider);
    if (userId == null) return;
    final db = ref.read(databaseProvider);
    final goal = await db.getDailyGoal(userId);
    final todaySeconds = await SessionDao(db).getTodaySeconds(userId);
    setState(() {
      _dailyGoalMinutes = goal;
      _todayMinutes = todaySeconds ~/ 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final garden = ref.watch(gardenProvider);
    final session = ref.watch(sessionProvider);

    final aliveTrees = garden.trees.where((t) => t.isAlive).length;
    final totalTrees = garden.trees.length;
    final completedSessions = session.status == SessionStatus.completed ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user != null ? 'Hey, $user' : 'Focus Garden',
          style: AppTypography.display2.copyWith(fontSize: 24),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text('0', style: AppTypography.label.copyWith(color: AppColors.secondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedEntry(
              delay: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppEffects.glassCard(accentColor: AppColors.primaryGlow, radius: AppRadius.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(Icons.radar, color: AppColors.primary, size: 20),
                        ),
                        const Spacer(),
                        Text('SOFT FOCUS', style: AppTypography.label.copyWith(color: AppColors.primary, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Ready to grow?', style: AppTypography.display2),
                    const SizedBox(height: 8),
                    Text('Start a session and watch your garden thrive',
                      style: AppTypography.body.copyWith(color: context.textMuted)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.6),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const SessionSetupScreen(),
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 22),
                              const SizedBox(width: 8),
                              const Text('Start Focus Session'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AnimatedEntry(
              delay: 1,
              child: Text('Today\'s Progress', style: AppTypography.heading1),
            ),
            const SizedBox(height: 12),
            _AnimatedEntry(
              delay: 1,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.surfaceElevated.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72, height: 72,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          progress: _dailyGoalMinutes > 0 ? _todayMinutes / _dailyGoalMinutes : 0,
                          isDark: context.isDark,
                        ),
                        child: Center(
                          child: Text('${_todayMinutes}m', style: AppTypography.caption.copyWith(
                            color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Goal', style: AppTypography.heading3),
                          const SizedBox(height: 2),
                          Text('$_todayMinutes of $_dailyGoalMinutes minutes',
                            style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _dailyGoalMinutes > 0 ? _todayMinutes / _dailyGoalMinutes : 0,
                              backgroundColor: context.surfaceHighlight,
                              color: AppColors.primary,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedEntry(
              delay: 1,
              child: Row(
                children: [
                  Expanded(child: _StatCard(
                    icon: Icons.eco_outlined,
                    label: 'Trees',
                    value: '$aliveTrees/$totalTrees',
                    color: AppColors.tertiary,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Sessions',
                    value: '$completedSessions',
                    color: AppColors.secondary,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '0',
                    color: AppColors.warning,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _AnimatedEntry(
              delay: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Garden', style: AppTypography.heading1),
                  if (garden.trees.isNotEmpty)
                    Text('See all', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedEntry(
              delay: 2,
              child: garden.isLoading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : garden.trees.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: AppEffects.glass(radius: AppRadius.lg),
                          child: Column(
                            children: [
                              Text('🌱', style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text('Your garden awaits', style: AppTypography.heading2),
                              const SizedBox(height: 4),
                              Text('Complete a session to plant your first seed',
                                style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: garden.trees.length > 5 ? 5 : garden.trees.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final tree = garden.trees[i];
                              return _GardenPreviewTile(tree: tree);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntry({required this.child, required this.delay});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 + widget.delay * 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon, required this.label, required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.15), width: 0.5),
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

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ProgressRingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = (isDark ? AppColors.surfaceHighlight : AppColorsLight.surfaceHighlight).withOpacity(0.5);

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [AppColors.primaryDark, AppColors.primary],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress.clamp(0, 1), false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) => old.progress != progress;
}

class _GardenPreviewTile extends StatelessWidget {
  final dynamic tree;

  const _GardenPreviewTile({required this.tree});

  String _emoji() {
    if (!tree.isAlive) return '🪦';
    switch (tree.species) {
      case 'oak': return '🌳';
      case 'pine': return '🌲';
      case 'cherry': return '🌸';
      default: return '🌱';
    }
  }

  Color _color(BuildContext context) {
    if (!tree.isAlive) return AppColors.textMuted;
    switch (tree.species) {
      case 'oak': return const Color(0xFF00CC6A);
      case 'pine': return const Color(0xFF3B82F6);
      case 'cherry': return const Color(0xFFFF4D6D);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(context);
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_emoji(), style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Stage ${tree.growthStage}',
              style: AppTypography.caption.copyWith(color: c, fontSize: 10)),
          ),
          if (!tree.isAlive)
            Text('Wilted', style: AppTypography.caption.copyWith(color: context.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
