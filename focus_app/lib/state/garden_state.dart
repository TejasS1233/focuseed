import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/daos/tree_dao.dart';
import '../core/db/database.dart';
import 'app_state.dart';

class GardenState {
  final List<Tree> trees;
  final bool isLoading;

  GardenState({this.trees = const [], this.isLoading = true});
}

class GardenNotifier extends Notifier<GardenState> {
  @override
  GardenState build() {
    ref.listen(userProvider, (_, next) {
      if (next != null) {
        loadTrees(next);
      }
    });
    final user = ref.read(userProvider);
    if (user != null) {
      loadTrees(user);
    }
    return GardenState();
  }

  Future<void> loadTrees(String userId) async {
    final dao = TreeDao(ref.read(databaseProvider));
    final trees = await dao.getTreesByUser(userId);
    state = GardenState(trees: trees, isLoading: false);
  }
}

final gardenProvider = NotifierProvider<GardenNotifier, GardenState>(
  GardenNotifier.new,
);
