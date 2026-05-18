import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/daos/blacklist_dao.dart';
import 'app_state.dart';

class BlacklistState {
  final List<String> blacklistedPackages;
  final bool isLoading;

  BlacklistState({this.blacklistedPackages = const [], this.isLoading = true});
}

class BlacklistNotifier extends Notifier<BlacklistState> {
  @override
  BlacklistState build() => BlacklistState();

  Future<void> load() async {
    final dao = BlacklistDao(ref.read(databaseProvider));
    final names = await dao.getAllPackageNames();
    state = BlacklistState(blacklistedPackages: names, isLoading: false);
  }

  Future<void> togglePackage(String packageName) async {
    final dao = BlacklistDao(ref.read(databaseProvider));
    final isCurrentlyBlacklisted = state.blacklistedPackages.contains(packageName);

    if (isCurrentlyBlacklisted) {
      await dao.remove(packageName);
      state = BlacklistState(
        blacklistedPackages: state.blacklistedPackages.where((p) => p != packageName).toList(),
        isLoading: false,
      );
    } else {
      await dao.add(packageName);
      state = BlacklistState(
        blacklistedPackages: [...state.blacklistedPackages, packageName],
        isLoading: false,
      );
    }
  }
}

final blacklistProvider = NotifierProvider<BlacklistNotifier, BlacklistState>(
  BlacklistNotifier.new,
);
