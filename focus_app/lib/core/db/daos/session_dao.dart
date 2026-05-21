import 'package:drift/drift.dart';
import '../database.dart';
import '../database.dart' as db;

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(AppDatabase db) : super(db);

  Future<void> insertSession(Session session) => into(sessions).insert(session);

  Future<List<Session>> getSessionsByUser(String userId) {
    return getAllSessions(userId);
  }

  Future<List<Session>> getAllSessions(String userId) {
    return (select(sessions)
      ..where((s) => s.userId.equals(userId))
      ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)]))
      .get();
  }

  Future<List<Session>> getSessionsInRange(String userId, DateTime start, DateTime end) {
    return (select(sessions)
      ..where((s) => s.userId.equals(userId) & s.startTime.isBetweenValues(start, end))
      ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)]))
      .get();
  }

  Future<List<Session>> getSessionsByTag(String userId, String tag) {
    return (select(sessions)
      ..where((s) => s.userId.equals(userId) & s.tag.equals(tag))
      ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)]))
      .get();
  }

  Future<List<String>> getDistinctTags(String userId) {
    final query = customSelect(
      'SELECT DISTINCT tag FROM sessions WHERE user_id = ? AND tag IS NOT NULL',
      variables: [Variable<String>(userId)],
    );
    return query.get().then((rows) => rows.map((r) => r.read<String>('tag')!).toList());
  }

  Future<Map<String, int>> getTaggedSeconds(String userId, DateTime start, DateTime end) {
    final query = customSelect(
      'SELECT tag, SUM(duration_seconds) as total FROM sessions '
      'WHERE user_id = ? AND tag IS NOT NULL AND start_time >= ? AND start_time <= ? '
      'GROUP BY tag ORDER BY total DESC',
      variables: [Variable<String>(userId), Variable<DateTime>(start), Variable<DateTime>(end)],
    );
    return query.get().then((rows) => {
      for (final r in rows)
        r.read<String>('tag')!: r.read<int>('total'),
    });
  }

  Future<List<Map<String, dynamic>>> getDailyTotals(String userId, DateTime start, DateTime end) {
    final query = customSelect(
      'SELECT DATE(start_time) as day, SUM(duration_seconds) as total '
      'FROM sessions WHERE user_id = ? AND start_time >= ? AND start_time <= ? '
      'GROUP BY day ORDER BY day ASC',
      variables: [Variable<String>(userId), Variable<DateTime>(start), Variable<DateTime>(end)],
    );
    return query.get().then((rows) => rows.map((r) => {
      'day': r.read<String>('day'),
      'total': r.read<int>('total'),
    }).toList());
  }

  Future<int> getCurrentStreak(String userId) async {
    final all = await (select(sessions)
      ..where((s) => s.userId.equals(userId) & s.outcome.equals('completed'))
      ..orderBy([(s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)]))
      .get();

    if (all.isEmpty) return 0;

    final dates = all.map((s) => s.startTime.toLocal()).toSet();
    final today = DateTime.now().toLocal();
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final day = DateTime(today.year, today.month, today.day - i);
      if (dates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day)) {
        streak++;
      } else if (i == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> getTodaySeconds(String userId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (select(sessions)
      ..where((s) => s.userId.equals(userId) & s.startTime.isBetweenValues(start, end)))
      .get();
    return rows.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  Future<int> getTotalSessions(String userId) async {
    final rows = await (select(sessions)..where((s) => s.userId.equals(userId))).get();
    return rows.length;
  }

  Future<int> getTotalSeconds(String userId) async {
    final all = await (select(sessions)..where((s) => s.userId.equals(userId))).get();
    return all.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  Future<double> getCompletionRate(String userId) async {
    final all = await (select(sessions)..where((s) => s.userId.equals(userId))).get();
    if (all.isEmpty) return 0;
    final completed = all.where((s) => s.outcome == 'completed').length;
    return completed / all.length;
  }

  Future<int> getFocusScore(String userId) async {
    final rate = await getCompletionRate(userId);
    final streak = await getCurrentStreak(userId);
    final totalHours = (await getTotalSeconds(userId)) / 3600;
    return ((rate * 50) + (streak.clamp(0, 30) * 1.5) + (totalHours.clamp(0, 100) * 0.5)).round();
  }
}
