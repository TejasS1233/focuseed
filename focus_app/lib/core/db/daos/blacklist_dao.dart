import 'package:drift/drift.dart';
import '../database.dart';

class BlacklistDao {
  final AppDatabase _db;
  BlacklistDao(this._db);

  Future<List<BlacklistEntryData>> getAll() =>
      _db.select(_db.blacklistEntry).get();

  Future<void> add(String packageName) =>
      _db.into(_db.blacklistEntry).insert(
        BlacklistEntryCompanion.insert(packageName: packageName),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> remove(String packageName) =>
      (_db.delete(_db.blacklistEntry)
        ..where((b) => b.packageName.equals(packageName))
      ).go();

  Future<bool> isBlacklisted(String packageName) async {
    final result = await (_db.select(_db.blacklistEntry)
      ..where((b) => b.packageName.equals(packageName))
    ).get();
    return result.isNotEmpty;
  }

  Future<List<String>> getAllPackageNames() async {
    final entries = await getAll();
    return entries.map((e) => e.packageName).toList();
  }
}
