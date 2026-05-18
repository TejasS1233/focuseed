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
      appBar: AppBar(title: const Text('Blocked Apps')),
      body: _loadingApps
          ? const Center(child: CircularProgressIndicator())
          : _allApps.isEmpty
              ? const Center(child: Text('No apps found'))
              : ListView.separated(
                  itemCount: _allApps.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final app = _allApps[i];
                    final packageName = app['packageName']!;
                    final name = app['name']!;
                    final isBlocked = blacklist.blacklistedPackages.contains(packageName);

                    if (packageName == 'com.focusapp.focus_app') {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: Icon(
                        Icons.android,
                        color: isBlocked ? UIColors.error : UIColors.gray400,
                      ),
                      title: Text(name),
                      subtitle: Text(packageName,
                        style: UITypography.caption.copyWith(color: UIColors.gray500)),
                      trailing: Switch(
                        value: isBlocked,
                        onChanged: (_) {
                          ref.read(blacklistProvider.notifier)
                              .togglePackage(packageName);
                        },
                        activeColor: UIColors.error,
                      ),
                    );
                  },
                ),
    );
  }
}
