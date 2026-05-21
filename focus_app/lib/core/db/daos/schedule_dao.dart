import 'package:drift/drift.dart';
import '../database.dart';

part 'schedule_dao.g.dart';

@DriftAccessor(tables: [Schedules])
class ScheduleDao extends DatabaseAccessor<AppDatabase> with _$ScheduleDaoMixin {
  ScheduleDao(AppDatabase db) : super(db);

  Future<List<Schedule>> getByUser(String userId) {
    return (select(schedules)..where((s) => s.userId.equals(userId))).get();
  }

  Future<List<Schedule>> getEnabled(String userId) {
    return (select(schedules)
      ..where((s) => s.userId.equals(userId) & s.enabled.equals(true)))
      .get();
  }

  Future<void> upsert(Schedule schedule) => into(schedules).insertOnConflictUpdate(schedule);

  Future<void> remove(String id) =>
      (delete(schedules)..where((s) => s.id.equals(id))).go();

  Future<void> setEnabled(String id, bool enabled) =>
      (update(schedules)..where((s) => s.id.equals(id))).write(SchedulesCompanion(enabled: Value(enabled)));
}
