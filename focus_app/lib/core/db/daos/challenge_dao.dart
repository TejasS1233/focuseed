import 'package:drift/drift.dart';
import '../database.dart';

part 'challenge_dao.g.dart';

@DriftAccessor(tables: [Challenges])
class ChallengeDao extends DatabaseAccessor<AppDatabase> with _$ChallengeDaoMixin {
  ChallengeDao(AppDatabase db) : super(db);

  Future<List<Challenge>> getActive(String userId) async {
    final q = select(challenges)
      ..where((c) => c.userId.equals(userId) & c.completedAt.isNull())
      ..orderBy([(c) => OrderingTerm(expression: c.startedAt, mode: OrderingMode.desc)]);
    return q.get();
  }

  Future<List<Challenge>> getCompleted(String userId) async {
    final q = select(challenges)
      ..where((c) => c.userId.equals(userId) & c.completedAt.isNotNull())
      ..orderBy([(c) => OrderingTerm(expression: c.completedAt, mode: OrderingMode.desc)]);
    return q.get();
  }

  Future<Challenge?> getByKey(String userId, String key) {
    return (select(challenges)
      ..where((c) => c.userId.equals(userId) & c.key.equals(key)))
      .getSingleOrNull();
  }

  Future<void> upsert(Challenge challenge) => into(challenges).insertOnConflictUpdate(challenge);

  Future<void> advanceProgress(String userId, String key, int amount) async {
    final existing = await getByKey(userId, key);
    if (existing == null) return;
    final newProgress = existing.progress + amount;
    await (update(challenges)..where((c) => c.id.equals(existing.id)))
      .write(ChallengesCompanion(progress: Value(newProgress)));
  }
}
