import '../database.dart';

class AchievementDao {
  final AppDatabase _db;
  AchievementDao(this._db);

  Future<void> insertAchievement(Achievement a) =>
      _db.into(_db.achievements).insert(a);

  Future<List<Achievement>> getAchievementsByUser(String userId) =>
      (_db.select(_db.achievements)..where((a) => a.userId.equals(userId))).get();

  Future<bool> isUnlocked(String userId, String key) async {
    final all = await getAchievementsByUser(userId);
    return all.any((a) => a.key == key);
  }
}
