import 'package:drift/drift.dart';
import '../database.dart';

class TreeDao {
  final AppDatabase _db;
  TreeDao(this._db);

  Future<void> insertTree(Tree tree) =>
      _db.into(_db.trees).insert(tree);

  Future<void> updateTree(Tree data) =>
      _db.update(_db.trees).replace(data);

  Stream<List<Tree>> watchTreesByUser(String userId) =>
      (_db.select(_db.trees)..where((t) => t.userId.equals(userId))).watch();

  Future<List<Tree>> getTreesByUser(String userId) =>
      (_db.select(_db.trees)..where((t) => t.userId.equals(userId))).get();

  Future<List<Tree>> getAliveTrees(String userId) async {
    final all = await getTreesByUser(userId);
    return all.where((t) => t.isAlive).toList();
  }

  Future<Tree?> getTreeById(String id) async {
    final result = await (_db.select(_db.trees)
      ..where((t) => t.id.equals(id))).get();
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> waterTree(Tree tree) async {
    await _db.update(_db.trees).replace(tree.copyWith(
      growthStage: tree.growthStage + 1,
      lastWateredAt: DateTime.now(),
    ));
  }

  Future<void> markDead(Tree tree) async {
    await _db.update(_db.trees).replace(tree.copyWith(
      isAlive: false,
      diedAt: Value(DateTime.now()),
    ));
  }
}
