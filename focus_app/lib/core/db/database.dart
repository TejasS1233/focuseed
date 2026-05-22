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
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(60))();
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
  TextColumn get tag => text().nullable()();
  IntColumn get focusScore => integer().nullable()();
  IntColumn get breakDuration => integer().nullable()();

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

class Decorations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  DateTimeColumn get placedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get tag => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get key => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get target => integer()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get period => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

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

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get sessionId => text()();
  IntColumn get rating => integer().withDefault(const Constant(3))();
  TextColumn get content => text()();
  TextColumn get mood => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BlacklistEntry extends Table {
  TextColumn get packageName => text()();

  @override
  Set<Column> get primaryKey => {packageName};
}

@DriftDatabase(
  tables: [Users, Sessions, Trees, Achievements, JournalEntries, BlacklistEntry, Decorations, Schedules, Challenges],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(journalEntries);
      }
      if (from < 3) {
        await m.addColumn(users, users.dailyGoalMinutes);
      }
      if (from < 4) {
        await m.addColumn(sessions, sessions.tag);
        await m.addColumn(sessions, sessions.focusScore);
        await m.addColumn(sessions, sessions.breakDuration);
        await m.createTable(decorations);
        await m.createTable(schedules);
        await m.createTable(challenges);
      }
    },
  );

  Future<Session?> getSessionById(String id) {
    return (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> getDailyGoal(String userId) async {
    final user = await (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
    return user?.dailyGoalMinutes ?? 60;
  }

  Future<void> setDailyGoal(String userId, int minutes) async {
    await (update(users)..where((u) => u.id.equals(userId))).write(UsersCompanion(
      dailyGoalMinutes: Value(minutes),
    ));
  }

  Future<String?> getExistingUserId() async {
    final user = await (select(users)..limit(1)).getSingleOrNull();
    return user?.id;
  }

  Future<void> createUser(String id, String displayName) async {
    await into(users).insert(UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateLongestStreak(String userId, int streak) async {
    final user = await (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (user != null && streak > user.longestStreak) {
      await (update(users)..where((u) => u.id.equals(userId))).write(UsersCompanion(
        longestStreak: Value(streak),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'focus_app.db'));
    return NativeDatabase(file);
  });
}
