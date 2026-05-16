import '../database.dart';

class SessionDao {
  final AppDatabase _db;
  SessionDao(this._db);

  Future<void> insertSession(Session session) =>
      _db.into(_db.sessions).insert(session);

  Future<void> updateSession(Session data) =>
      _db.update(_db.sessions).replace(data);

  Future<Session?> getSession(String id) => _db.getSessionById(id);

  Stream<List<Session>> watchSessionsByUser(String userId) =>
      (_db.select(_db.sessions)..where((s) => s.userId.equals(userId))).watch();

  Future<List<Session>> getSessionsByUser(String userId) =>
      (_db.select(_db.sessions)..where((s) => s.userId.equals(userId))).get();

  Future<int> getTotalSecondsForUser(String userId) async {
    final sessions = await getSessionsByUser(userId);
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }
}
