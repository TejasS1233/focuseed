import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/blacklist_state.dart';
import '../core/services/lock_service.dart';
import '../theme/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final name = _controller.text.trim();
    final userId = name.isEmpty ? _generateId() : name;
    ref.read(userProvider.notifier).state = userId;
    final db = ref.read(databaseProvider);
    await db.createUser(userId, name.isEmpty ? 'Gardener' : name);
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const _SetupBlacklistScreen(),
    ));
  }

  String _generateId() => 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: context.gradientBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                    boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.4),
                  ),
                  child: const Center(
                    child: Text('🌱', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text('Focus Garden', style: AppTypography.display1),
                const SizedBox(height: 12),
                Text(
                  'Grow your focus, one session at a time.',
                  style: AppTypography.body.copyWith(color: context.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Name input
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your name (optional)',
                    prefixIcon: Icon(Icons.person_outline, size: 18, color: context.textMuted),
                  ),
                ),
                const SizedBox(height: 24),
                // CTA
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.5),
                    ),
                    child: ElevatedButton(
                      onPressed: _complete,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Start Growing'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupBlacklistScreen extends ConsumerStatefulWidget {
  const _SetupBlacklistScreen();

  @override
  ConsumerState<_SetupBlacklistScreen> createState() => _SetupBlacklistScreenState();
}

class _SetupBlacklistScreenState extends ConsumerState<_SetupBlacklistScreen> {
  List<Map<String, String>> _allApps = [];
  bool _loadingApps = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
    Future.microtask(() {
      ref.read(blacklistProvider.notifier).load();
    });
  }

  Future<void> _loadApps() async {
    final apps = await LockService.getInstalledApps();
    if (mounted) {
      setState(() {
        _allApps = apps;
        _loadingApps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blacklist = ref.watch(blacklistProvider);
    final blockedCount = blacklist.blacklistedPackages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Block Distractions', style: AppTypography.display2.copyWith(fontSize: 22)),
      ),
      body: _loadingApps
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'Block apps that distract you during hard lock sessions.',
                    style: AppTypography.body.copyWith(color: context.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _allApps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final app = _allApps[i];
                      final pkg = app['packageName']!;
                      final name = app['name']!;
                      final blocked = blacklist.blacklistedPackages.contains(pkg);
                      return Container(
                        decoration: BoxDecoration(
                          color: context.surfaceElevated.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: blocked ? AppColors.error.withOpacity(0.2) : context.border,
                            width: 0.5,
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: blocked
                                  ? AppColors.error.withOpacity(0.1)
                                  : context.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Center(
                              child: Text(name[0].toUpperCase(),
                                style: AppTypography.heading3.copyWith(
                                  color: blocked ? AppColors.error : context.textMuted,
                                  fontSize: 16,
                                )),
                            ),
                          ),
                          title: Text(name, style: AppTypography.body),
                          subtitle: Text(pkg, style: AppTypography.caption.copyWith(color: context.textMuted)),
                          trailing: Switch(
                            value: blocked,
                            activeColor: AppColors.error,
                            onChanged: (_) => ref.read(blacklistProvider.notifier).togglePackage(pkg),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                        child: Text(blockedCount > 0
                            ? 'Lock In ($blockedCount blocked)'
                            : 'Skip, I\'ll manage later'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
