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

  Future<List<String>> load() async {
    final dao = BlacklistDao(ref.read(databaseProvider));
    final names = await dao.getAllPackageNames();
    state = BlacklistState(blacklistedPackages: names, isLoading: false);
    return names;
  }

  Future<void> togglePackage(String packageName) async {
    final currently = state.blacklistedPackages.contains(packageName);
    final updated = currently
        ? state.blacklistedPackages.where((p) => p != packageName).toList()
        : [...state.blacklistedPackages, packageName];

    state = BlacklistState(blacklistedPackages: updated, isLoading: false);

    try {
      final dao = BlacklistDao(ref.read(databaseProvider));
      if (currently) {
        await dao.remove(packageName);
      } else {
        await dao.add(packageName);
      }
    } catch (e) {
      state = BlacklistState(blacklistedPackages: state.blacklistedPackages, isLoading: false);
    }
  }
}

final blacklistProvider = NotifierProvider<BlacklistNotifier, BlacklistState>(
  BlacklistNotifier.new,
);
