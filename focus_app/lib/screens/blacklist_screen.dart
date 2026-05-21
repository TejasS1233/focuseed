import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lock_service.dart';
import '../state/blacklist_state.dart';
import '../theme/theme.dart';

class BlacklistScreen extends ConsumerStatefulWidget {
  const BlacklistScreen({super.key});

  @override
  ConsumerState<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends ConsumerState<BlacklistScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Apps', style: AppTypography.display2.copyWith(fontSize: 22)),
      ),
      body: _loadingApps
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _allApps.isEmpty
              ? Center(
                  child: Text('No apps found', style: AppTypography.body.copyWith(color: context.textMuted)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _allApps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final app = _allApps[i];
                    final packageName = app['packageName']!;
                    final name = app['name']!;
                    final isBlocked = blacklist.blacklistedPackages.contains(packageName);

                    if (packageName == 'com.focusapp.focus_app') {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: context.surfaceElevated.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isBlocked ? AppColors.error.withOpacity(0.2) : context.border,
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: isBlocked
                                ? AppColors.error.withOpacity(0.1)
                                : context.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(name[0].toUpperCase(),
                              style: AppTypography.heading3.copyWith(
                                color: isBlocked ? AppColors.error : context.textMuted,
                                fontSize: 16,
                              )),
                          ),
                        ),
                        title: Text(name, style: AppTypography.body),
                        subtitle: Text(packageName,
                          style: AppTypography.caption.copyWith(color: context.textMuted)),
                        trailing: Switch(
                          value: isBlocked,
                          activeColor: AppColors.error,
                          onChanged: (_) {
                            ref.read(blacklistProvider.notifier).togglePackage(packageName);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
