import '../db/database.dart';
import '../db/daos/tree_dao.dart';
import 'session_service.dart';

class TreeLifecycleService {
  final TreeDao _dao;
  final SessionService _sessionService = SessionService();

  TreeLifecycleService(AppDatabase db) : _dao = TreeDao(db);

  Future<void> plantTree({
    required String userId,
    String? sessionId,
    int durationSeconds = 0,
    String mode = 'soft',
    String species = 'oak',
  }) async {
    final stage = _sessionService.calculateGrowthStage(durationSeconds, mode: mode);
    await _dao.insertTree(Tree(
      id: _sessionService.generateId(),
      userId: userId,
      sessionId: sessionId,
      species: species,
      growthStage: stage,
      isAlive: true,
      plantedAt: DateTime.now(),
      diedAt: null,
      lastWateredAt: DateTime.now(),
    ));
  }

  Future<void> waterTree(String treeId) async {
    final tree = await _dao.getTreeById(treeId);
    if (tree == null || !tree.isAlive) return;
    await _dao.waterTree(tree);
  }

  Future<void> waterAll(String userId) async {
    final trees = await _dao.getAliveTrees(userId);
    for (final tree in trees) {
      await _dao.waterTree(tree);
    }
  }

  Future<int> checkForDeadTrees(String userId) async {
    final alive = await _dao.getAliveTrees(userId);
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 48));
    int died = 0;

    for (final tree in alive) {
      if (tree.lastWateredAt.isBefore(cutoff)) {
        await _dao.markDead(tree);
        died++;
      }
    }
    return died;
  }

  Future<List<Tree>> getAliveTrees(String userId) =>
      _dao.getAliveTrees(userId);

  Future<List<Tree>> getAllTrees(String userId) =>
      _dao.getTreesByUser(userId);
}
