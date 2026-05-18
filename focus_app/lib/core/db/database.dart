import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalFocusSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get mode => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get intention => text().nullable()();
  TextColumn get ambientSound => text().nullable()();
  TextColumn get outcome => text()();
  TextColumn get roomId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Trees extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get species => text()();
  IntColumn get growthStage => integer().withDefault(const Constant(0))();
  BoolColumn get isAlive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get plantedAt => dateTime()();
  DateTimeColumn get diedAt => dateTime().nullable()();
  DateTimeColumn get lastWateredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get key => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BlacklistEntry extends Table {
  TextColumn get packageName => text()();

  @override
  Set<Column> get primaryKey => {packageName};
}

@DriftDatabase(
  tables: [Users, Sessions, Trees, Achievements, BlacklistEntry],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<Session?> getSessionById(String id) {
    return (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'focus_app.db'));
    return NativeDatabase(file);
  });
}
