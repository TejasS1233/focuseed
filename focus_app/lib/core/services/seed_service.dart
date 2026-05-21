import 'dart:math';
import 'package:drift/drift.dart';
import '../db/database.dart';

class SeedService {
  final AppDatabase db;
  SeedService(this.db);

  static final _rng = Random(42);
  static final _intentions = [
    'Deep work on auth module',
    'Studying system design patterns',
    'Reading distributed systems papers',
    'Building Flutter UI components',
    'Code review session',
    'Learning Riverpod internals',
    'Database sharding research',
    'API design for microservices',
  ];
  static final _tags = [
    'system-design',
    'flutter',
    'ai',
    'backend',
    'reading',
  ];
  static final _modes = ['soft', 'hard', 'soft', 'soft', 'hard'];
  static final _species = ['oak', 'pine', 'cherry', 'sprout'];
  static final _moods = [
    'focused',
    'tired',
    'energized',
    'neutral',
    'distracted',
  ];
  static final _reflections = [
    'Good session, made solid progress on the architecture',
    'Struggled to focus initially but entered flow state',
    'Finally understood the CQRS pattern implementation',
    'Too many distractions today, need to improve',
    'Excellent deep work session, very productive',
    'Worked through the database migration strategy',
    'Getting comfortable with the testing framework',
    'Need to review the concurrency model again',
  ];
  static final _challengeDefs = [
    ('daily_7', '7-Day Streak', 'Complete sessions for 7 consecutive days', 7, 'streak'),
    ('session_20', '20 Sessions', 'Complete 20 focus sessions', 20, 'session'),
    ('focus_5h', '5 Hour Focus', 'Accumulate 5 hours of total focus', 18000, 'focus'),
  ];

  Future<void> seedAll(String userId) async {
    await _seedUser(userId);
    final sessionIds = await _seedSessions(userId);
    await _seedTrees(userId, sessionIds);
    await _seedJournal(userId, sessionIds);
    await _seedAchievements(userId);
    await _seedDecorations(userId);
    await _seedChallenges(userId);
  }

  Future<void> _seedUser(String userId) async {
    final existing = await db.getExistingUserId();
    if (existing == null) {
      await db.createUser(userId, 'Tejas');
    }
    await db.setDailyGoal(userId, 120);
  }

  Future<List<String>> _seedSessions(String userId) async {
    final ids = <String>[];
    final now = DateTime.now();

    for (int i = 0; i < 25; i++) {
      final daysAgo = i * 0.6;
      final startTime = now.subtract(Duration(
        hours: (daysAgo * 24).round(),
        minutes: _rng.nextInt(480),
      ));
      final duration = Duration(seconds: 600 + _rng.nextInt(5400));
      final isCompleted = _rng.nextDouble() > 0.15;
      final id = _id();
      final tag = _tags[_rng.nextInt(_tags.length)];

      await db.into(db.sessions).insert(SessionsCompanion(
        id: Value(id),
        userId: Value(userId),
        mode: Value(_modes[_rng.nextInt(_modes.length)]),
        startTime: Value(startTime),
        endTime: Value(isCompleted ? startTime.add(duration) : null),
        durationSeconds: Value(duration.inSeconds),
        intention: Value(_intentions[_rng.nextInt(_intentions.length)]),
        ambientSound: Value(_rng.nextBool() ? null : ['rain', 'lofi', 'whitenoise', 'forest', 'drone'][_rng.nextInt(5)]),
        outcome: Value(isCompleted ? 'completed' : 'abandoned'),
        tag: Value(tag),
        focusScore: Value(isCompleted ? 50 + _rng.nextInt(51) : null),
        breakDuration: Value(isCompleted ? (_rng.nextBool() ? 300 + _rng.nextInt(600) : null) : null),
        roomId: const Value.absent(),
      ));
      ids.add(id);
    }
    return ids;
  }

  Future<void> _seedTrees(String userId, List<String> sessionIds) async {
    final now = DateTime.now();
    for (int i = 0; i < sessionIds.length; i++) {
      if (_rng.nextDouble() > 0.7) continue;
      final daysAgo = i * 0.6;
      final plantedAt = now.subtract(Duration(hours: (daysAgo * 24).round()));
      await db.into(db.trees).insert(TreesCompanion(
        id: Value(_id()),
        userId: Value(userId),
        sessionId: Value(sessionIds[i]),
        species: Value(_species[_rng.nextInt(_species.length)]),
        growthStage: Value(_rng.nextInt(4)),
        isAlive: Value(_rng.nextDouble() > 0.1),
        plantedAt: Value(plantedAt),
        lastWateredAt: Value(plantedAt.add(Duration(hours: _rng.nextInt(48)))),
        diedAt: Value(_rng.nextDouble() > 0.1 ? null : plantedAt.add(const Duration(days: 3))),
      ));
    }
  }

  Future<void> _seedJournal(String userId, List<String> sessionIds) async {
    for (int i = 0; i < sessionIds.length; i++) {
      if (_rng.nextDouble() > 0.4) continue;
      await db.into(db.journalEntries).insert(JournalEntriesCompanion(
        id: Value(_id()),
        userId: Value(userId),
        sessionId: Value(sessionIds[i]),
        rating: Value(2 + _rng.nextInt(4)),
        content: Value(_reflections[_rng.nextInt(_reflections.length)]),
        mood: Value(_moods[_rng.nextInt(_moods.length)]),
        createdAt: Value(DateTime.now().subtract(Duration(hours: (i * 14).round()))),
      ));
    }
  }

  Future<void> _seedAchievements(String userId) async {
    final achievements = [
      ('first_session', 'First Seed', 'Complete your first session'),
      ('ten_sessions', 'Sprout', 'Complete 10 sessions'),
      ('streak_3', 'Sapling', 'Maintain a 3-day streak'),
      ('focus_1h', 'Budding', 'Focus for 1 total hour'),
      ('focus_10h', 'Gardener', 'Focus for 10 total hours'),
    ];
    for (final (key, title, desc) in achievements) {
      await db.into(db.achievements).insert(AchievementsCompanion(
        id: Value(_id()),
        userId: Value(userId),
        key: Value(key),
        title: Value(title),
        description: Value(desc),
        unlockedAt: Value(DateTime.now().subtract(Duration(days: _rng.nextInt(14)))),
      ));
    }
  }

  Future<void> _seedDecorations(String userId) async {
    final types = ['stone', 'flower', 'grass', 'mushroom'];
    for (int i = 0; i < 8; i++) {
      await db.into(db.decorations).insert(DecorationsCompanion(
        id: Value(_id()),
        userId: Value(userId),
        type: Value(types[_rng.nextInt(types.length)]),
        x: Value(0.1 + _rng.nextDouble() * 0.8),
        y: Value(0.1 + _rng.nextDouble() * 0.8),
        placedAt: Value(DateTime.now()),
      ));
    }
  }

  Future<void> _seedChallenges(String userId) async {
    for (final (key, title, desc, target, period) in _challengeDefs) {
      final progress = (target * 0.6).round();
      await db.into(db.challenges).insert(ChallengesCompanion(
        id: Value(_id()),
        userId: Value(userId),
        key: Value(key),
        title: Value(title),
        description: Value(desc),
        target: Value(target),
        progress: Value(progress),
        period: Value(period),
        startedAt: Value(DateTime.now().subtract(const Duration(days: 7))),
      ));
    }
  }

  String _id() =>
      'seed_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(99999)}';
}
