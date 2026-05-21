import 'package:drift/drift.dart';
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

  Future<List<Session>> getSessionsInRange(String userId, DateTime from, DateTime to) =>
      (_db.select(_db.sessions)
        ..where((s) => s.userId.equals(userId) & s.startTime.isBetween(Variable(from), Variable(to)))
        ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)])
      ).get();

  Future<int> getTodaySeconds(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessions = await getSessionsInRange(userId, today, now.add(const Duration(days: 1)));
    return sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
  }

  Future<Map<String, int>> getDailyTotals(String userId, int days) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day - days + 1);
    final sessions = await getSessionsInRange(userId, from, now);

    final totals = <String, int>{};
    for (int i = 0; i < days; i++) {
      final d = DateTime(now.year, now.month, now.day - i);
      totals[_dateKey(d)] = 0;
    }

    for (final s in sessions) {
      final key = _dateKey(s.startTime);
      if (totals.containsKey(key)) {
        totals[key] = (totals[key] ?? 0) + s.durationSeconds;
      }
    }
    return totals;
  }

  Future<int> getCurrentStreak(String userId) async {
    final sessions = await getSessionsByUser(userId);
    if (sessions.isEmpty) return 0;

    final days = sessions
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < days.length; i++) {
      final expected = todayNorm.subtract(Duration(days: streak));
      if (days[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
