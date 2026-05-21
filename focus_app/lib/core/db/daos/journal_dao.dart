import 'package:drift/drift.dart';
import '../database.dart';

class JournalDao {
  final AppDatabase _db;
  JournalDao(this._db);

  Future<void> insertEntry(JournalEntry entry) =>
      _db.into(_db.journalEntries).insert(entry);

  Future<List<JournalEntry>> getEntriesByUser(String userId) =>
      (_db.select(_db.journalEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)])
      ).get();

  Stream<List<JournalEntry>> watchEntriesByUser(String userId) =>
      (_db.select(_db.journalEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)])
      ).watch();

  Future<void> deleteEntry(String id) =>
      (_db.delete(_db.journalEntries)..where((e) => e.id.equals(id))).go();
}
