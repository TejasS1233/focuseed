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

  void _complete() {
    final name = _controller.text.trim();
    final userId = name.isEmpty ? _generateId() : name;
    ref.read(userProvider.notifier).state = userId;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const _SetupBlacklistScreen(),
    ));
  }

  String _generateId() => 'user_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(UISpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 80, color: UIColors.primary),
              const SizedBox(height: UISpacing.lg),
              Text('Welcome to Focus Garden',
                style: UITypography.heading1),
              const SizedBox(height: UISpacing.sm),
              Text(
                'Grow your focus, one session at a time.',
                style: UITypography.body.copyWith(color: UIColors.gray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UISpacing.xl),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Your name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: UISpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _complete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.primary,
                    foregroundColor: UIColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Start Growing',
                    style: UITypography.body.copyWith(
                      fontWeight: FontWeight.w600)),
                ),
              ),
            ],
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
      appBar: AppBar(title: const Text('Block Distractions')),
      body: _loadingApps
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Block apps that distract you during hard lock sessions.',
                    style: UITypography.body.copyWith(color: UIColors.gray500),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _allApps.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final app = _allApps[i];
                      final pkg = app['packageName']!;
                      final name = app['name']!;
                      final blocked = blacklist.blacklistedPackages.contains(pkg);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: blocked ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          child: Text(name[0].toUpperCase(),
                            style: TextStyle(color: blocked ? Colors.red : Colors.grey)),
                        ),
                        title: Text(name),
                        trailing: Switch(
                          value: blocked,
                          onChanged: (_) => ref.read(blacklistProvider.notifier).togglePackage(pkg),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.primary,
                          foregroundColor: UIColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
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
