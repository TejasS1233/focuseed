// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _streakCountMeta =
      const VerificationMeta('streakCount');
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
      'streak_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _longestStreakMeta =
      const VerificationMeta('longestStreak');
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
      'longest_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalFocusSecondsMeta =
      const VerificationMeta('totalFocusSeconds');
  @override
  late final GeneratedColumn<int> totalFocusSeconds = GeneratedColumn<int>(
      'total_focus_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        streakCount,
        longestStreak,
        totalFocusSeconds,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('streak_count')) {
      context.handle(
          _streakCountMeta,
          streakCount.isAcceptableOrUnknown(
              data['streak_count']!, _streakCountMeta));
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
          _longestStreakMeta,
          longestStreak.isAcceptableOrUnknown(
              data['longest_streak']!, _longestStreakMeta));
    }
    if (data.containsKey('total_focus_seconds')) {
      context.handle(
          _totalFocusSecondsMeta,
          totalFocusSeconds.isAcceptableOrUnknown(
              data['total_focus_seconds']!, _totalFocusSecondsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      streakCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_count'])!,
      longestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_streak'])!,
      totalFocusSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_focus_seconds'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? displayName;
  final int streakCount;
  final int longestStreak;
  final int totalFocusSeconds;
  final DateTime createdAt;
  const User(
      {required this.id,
      this.displayName,
      required this.streakCount,
      required this.longestStreak,
      required this.totalFocusSeconds,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['streak_count'] = Variable<int>(streakCount);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['total_focus_seconds'] = Variable<int>(totalFocusSeconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      streakCount: Value(streakCount),
      longestStreak: Value(longestStreak),
      totalFocusSeconds: Value(totalFocusSeconds),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      totalFocusSeconds: serializer.fromJson<int>(json['totalFocusSeconds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String?>(displayName),
      'streakCount': serializer.toJson<int>(streakCount),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'totalFocusSeconds': serializer.toJson<int>(totalFocusSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {String? id,
          Value<String?> displayName = const Value.absent(),
          int? streakCount,
          int? longestStreak,
          int? totalFocusSeconds,
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        displayName: displayName.present ? displayName.value : this.displayName,
        streakCount: streakCount ?? this.streakCount,
        longestStreak: longestStreak ?? this.longestStreak,
        totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      streakCount:
          data.streakCount.present ? data.streakCount.value : this.streakCount,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      totalFocusSeconds: data.totalFocusSeconds.present
          ? data.totalFocusSeconds.value
          : this.totalFocusSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('streakCount: $streakCount, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, streakCount, longestStreak,
      totalFocusSeconds, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.streakCount == this.streakCount &&
          other.longestStreak == this.longestStreak &&
          other.totalFocusSeconds == this.totalFocusSeconds &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> displayName;
  final Value<int> streakCount;
  final Value<int> longestStreak;
  final Value<int> totalFocusSeconds;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.displayName = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? streakCount,
    Expression<int>? longestStreak,
    Expression<int>? totalFocusSeconds,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (streakCount != null) 'streak_count': streakCount,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (totalFocusSeconds != null) 'total_focus_seconds': totalFocusSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? displayName,
      Value<int>? streakCount,
      Value<int>? longestStreak,
      Value<int>? totalFocusSeconds,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (totalFocusSeconds.present) {
      map['total_focus_seconds'] = Variable<int>(totalFocusSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('streakCount: $streakCount, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _intentionMeta =
      const VerificationMeta('intention');
  @override
  late final GeneratedColumn<String> intention = GeneratedColumn<String>(
      'intention', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ambientSoundMeta =
      const VerificationMeta('ambientSound');
  @override
  late final GeneratedColumn<String> ambientSound = GeneratedColumn<String>(
      'ambient_sound', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
      'room_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        mode,
        startTime,
        endTime,
        durationSeconds,
        intention,
        ambientSound,
        outcome,
        roomId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('intention')) {
      context.handle(_intentionMeta,
          intention.isAcceptableOrUnknown(data['intention']!, _intentionMeta));
    }
    if (data.containsKey('ambient_sound')) {
      context.handle(
          _ambientSoundMeta,
          ambientSound.isAcceptableOrUnknown(
              data['ambient_sound']!, _ambientSoundMeta));
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      intention: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intention']),
      ambientSound: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ambient_sound']),
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      roomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_id']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String userId;
  final String mode;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String? intention;
  final String? ambientSound;
  final String outcome;
  final String? roomId;
  const Session(
      {required this.id,
      required this.userId,
      required this.mode,
      required this.startTime,
      this.endTime,
      required this.durationSeconds,
      this.intention,
      this.ambientSound,
      required this.outcome,
      this.roomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['mode'] = Variable<String>(mode);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || intention != null) {
      map['intention'] = Variable<String>(intention);
    }
    if (!nullToAbsent || ambientSound != null) {
      map['ambient_sound'] = Variable<String>(ambientSound);
    }
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      mode: Value(mode),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: Value(durationSeconds),
      intention: intention == null && nullToAbsent
          ? const Value.absent()
          : Value(intention),
      ambientSound: ambientSound == null && nullToAbsent
          ? const Value.absent()
          : Value(ambientSound),
      outcome: Value(outcome),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      mode: serializer.fromJson<String>(json['mode']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      intention: serializer.fromJson<String?>(json['intention']),
      ambientSound: serializer.fromJson<String?>(json['ambientSound']),
      outcome: serializer.fromJson<String>(json['outcome']),
      roomId: serializer.fromJson<String?>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'mode': serializer.toJson<String>(mode),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'intention': serializer.toJson<String?>(intention),
      'ambientSound': serializer.toJson<String?>(ambientSound),
      'outcome': serializer.toJson<String>(outcome),
      'roomId': serializer.toJson<String?>(roomId),
    };
  }

  Session copyWith(
          {String? id,
          String? userId,
          String? mode,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          int? durationSeconds,
          Value<String?> intention = const Value.absent(),
          Value<String?> ambientSound = const Value.absent(),
          String? outcome,
          Value<String?> roomId = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        mode: mode ?? this.mode,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        intention: intention.present ? intention.value : this.intention,
        ambientSound:
            ambientSound.present ? ambientSound.value : this.ambientSound,
        outcome: outcome ?? this.outcome,
        roomId: roomId.present ? roomId.value : this.roomId,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      mode: data.mode.present ? data.mode.value : this.mode,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      intention: data.intention.present ? data.intention.value : this.intention,
      ambientSound: data.ambientSound.present
          ? data.ambientSound.value
          : this.ambientSound,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('mode: $mode, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('intention: $intention, ')
          ..write('ambientSound: $ambientSound, ')
          ..write('outcome: $outcome, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, mode, startTime, endTime,
      durationSeconds, intention, ambientSound, outcome, roomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.mode == this.mode &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.intention == this.intention &&
          other.ambientSound == this.ambientSound &&
          other.outcome == this.outcome &&
          other.roomId == this.roomId);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> mode;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> durationSeconds;
  final Value<String?> intention;
  final Value<String?> ambientSound;
  final Value<String> outcome;
  final Value<String?> roomId;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.mode = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.intention = const Value.absent(),
    this.ambientSound = const Value.absent(),
    this.outcome = const Value.absent(),
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String userId,
    required String mode,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.intention = const Value.absent(),
    this.ambientSound = const Value.absent(),
    required String outcome,
    this.roomId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        mode = Value(mode),
        startTime = Value(startTime),
        outcome = Value(outcome);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? mode,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<String>? intention,
    Expression<String>? ambientSound,
    Expression<String>? outcome,
    Expression<String>? roomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (mode != null) 'mode': mode,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (intention != null) 'intention': intention,
      if (ambientSound != null) 'ambient_sound': ambientSound,
      if (outcome != null) 'outcome': outcome,
      if (roomId != null) 'room_id': roomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? mode,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<int>? durationSeconds,
      Value<String?>? intention,
      Value<String?>? ambientSound,
      Value<String>? outcome,
      Value<String?>? roomId,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      intention: intention ?? this.intention,
      ambientSound: ambientSound ?? this.ambientSound,
      outcome: outcome ?? this.outcome,
      roomId: roomId ?? this.roomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (intention.present) {
      map['intention'] = Variable<String>(intention.value);
    }
    if (ambientSound.present) {
      map['ambient_sound'] = Variable<String>(ambientSound.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('mode: $mode, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('intention: $intention, ')
          ..write('ambientSound: $ambientSound, ')
          ..write('outcome: $outcome, ')
          ..write('roomId: $roomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreesTable extends Trees with TableInfo<$TreesTable, Tree> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _growthStageMeta =
      const VerificationMeta('growthStage');
  @override
  late final GeneratedColumn<int> growthStage = GeneratedColumn<int>(
      'growth_stage', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isAliveMeta =
      const VerificationMeta('isAlive');
  @override
  late final GeneratedColumn<bool> isAlive = GeneratedColumn<bool>(
      'is_alive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_alive" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _plantedAtMeta =
      const VerificationMeta('plantedAt');
  @override
  late final GeneratedColumn<DateTime> plantedAt = GeneratedColumn<DateTime>(
      'planted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _diedAtMeta = const VerificationMeta('diedAt');
  @override
  late final GeneratedColumn<DateTime> diedAt = GeneratedColumn<DateTime>(
      'died_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastWateredAtMeta =
      const VerificationMeta('lastWateredAt');
  @override
  late final GeneratedColumn<DateTime> lastWateredAt =
      GeneratedColumn<DateTime>('last_watered_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        sessionId,
        species,
        growthStage,
        isAlive,
        plantedAt,
        diedAt,
        lastWateredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trees';
  @override
  VerificationContext validateIntegrity(Insertable<Tree> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('growth_stage')) {
      context.handle(
          _growthStageMeta,
          growthStage.isAcceptableOrUnknown(
              data['growth_stage']!, _growthStageMeta));
    }
    if (data.containsKey('is_alive')) {
      context.handle(_isAliveMeta,
          isAlive.isAcceptableOrUnknown(data['is_alive']!, _isAliveMeta));
    }
    if (data.containsKey('planted_at')) {
      context.handle(_plantedAtMeta,
          plantedAt.isAcceptableOrUnknown(data['planted_at']!, _plantedAtMeta));
    } else if (isInserting) {
      context.missing(_plantedAtMeta);
    }
    if (data.containsKey('died_at')) {
      context.handle(_diedAtMeta,
          diedAt.isAcceptableOrUnknown(data['died_at']!, _diedAtMeta));
    }
    if (data.containsKey('last_watered_at')) {
      context.handle(
          _lastWateredAtMeta,
          lastWateredAt.isAcceptableOrUnknown(
              data['last_watered_at']!, _lastWateredAtMeta));
    } else if (isInserting) {
      context.missing(_lastWateredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tree map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tree(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      growthStage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}growth_stage'])!,
      isAlive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_alive'])!,
      plantedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}planted_at'])!,
      diedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}died_at']),
      lastWateredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_watered_at'])!,
    );
  }

  @override
  $TreesTable createAlias(String alias) {
    return $TreesTable(attachedDatabase, alias);
  }
}

class Tree extends DataClass implements Insertable<Tree> {
  final String id;
  final String userId;
  final String? sessionId;
  final String species;
  final int growthStage;
  final bool isAlive;
  final DateTime plantedAt;
  final DateTime? diedAt;
  final DateTime lastWateredAt;
  const Tree(
      {required this.id,
      required this.userId,
      this.sessionId,
      required this.species,
      required this.growthStage,
      required this.isAlive,
      required this.plantedAt,
      this.diedAt,
      required this.lastWateredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['species'] = Variable<String>(species);
    map['growth_stage'] = Variable<int>(growthStage);
    map['is_alive'] = Variable<bool>(isAlive);
    map['planted_at'] = Variable<DateTime>(plantedAt);
    if (!nullToAbsent || diedAt != null) {
      map['died_at'] = Variable<DateTime>(diedAt);
    }
    map['last_watered_at'] = Variable<DateTime>(lastWateredAt);
    return map;
  }

  TreesCompanion toCompanion(bool nullToAbsent) {
    return TreesCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      species: Value(species),
      growthStage: Value(growthStage),
      isAlive: Value(isAlive),
      plantedAt: Value(plantedAt),
      diedAt:
          diedAt == null && nullToAbsent ? const Value.absent() : Value(diedAt),
      lastWateredAt: Value(lastWateredAt),
    );
  }

  factory Tree.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tree(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      species: serializer.fromJson<String>(json['species']),
      growthStage: serializer.fromJson<int>(json['growthStage']),
      isAlive: serializer.fromJson<bool>(json['isAlive']),
      plantedAt: serializer.fromJson<DateTime>(json['plantedAt']),
      diedAt: serializer.fromJson<DateTime?>(json['diedAt']),
      lastWateredAt: serializer.fromJson<DateTime>(json['lastWateredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'species': serializer.toJson<String>(species),
      'growthStage': serializer.toJson<int>(growthStage),
      'isAlive': serializer.toJson<bool>(isAlive),
      'plantedAt': serializer.toJson<DateTime>(plantedAt),
      'diedAt': serializer.toJson<DateTime?>(diedAt),
      'lastWateredAt': serializer.toJson<DateTime>(lastWateredAt),
    };
  }

  Tree copyWith(
          {String? id,
          String? userId,
          Value<String?> sessionId = const Value.absent(),
          String? species,
          int? growthStage,
          bool? isAlive,
          DateTime? plantedAt,
          Value<DateTime?> diedAt = const Value.absent(),
          DateTime? lastWateredAt}) =>
      Tree(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        species: species ?? this.species,
        growthStage: growthStage ?? this.growthStage,
        isAlive: isAlive ?? this.isAlive,
        plantedAt: plantedAt ?? this.plantedAt,
        diedAt: diedAt.present ? diedAt.value : this.diedAt,
        lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      );
  Tree copyWithCompanion(TreesCompanion data) {
    return Tree(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      species: data.species.present ? data.species.value : this.species,
      growthStage:
          data.growthStage.present ? data.growthStage.value : this.growthStage,
      isAlive: data.isAlive.present ? data.isAlive.value : this.isAlive,
      plantedAt: data.plantedAt.present ? data.plantedAt.value : this.plantedAt,
      diedAt: data.diedAt.present ? data.diedAt.value : this.diedAt,
      lastWateredAt: data.lastWateredAt.present
          ? data.lastWateredAt.value
          : this.lastWateredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tree(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('species: $species, ')
          ..write('growthStage: $growthStage, ')
          ..write('isAlive: $isAlive, ')
          ..write('plantedAt: $plantedAt, ')
          ..write('diedAt: $diedAt, ')
          ..write('lastWateredAt: $lastWateredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, sessionId, species, growthStage,
      isAlive, plantedAt, diedAt, lastWateredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tree &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionId == this.sessionId &&
          other.species == this.species &&
          other.growthStage == this.growthStage &&
          other.isAlive == this.isAlive &&
          other.plantedAt == this.plantedAt &&
          other.diedAt == this.diedAt &&
          other.lastWateredAt == this.lastWateredAt);
}

class TreesCompanion extends UpdateCompanion<Tree> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> sessionId;
  final Value<String> species;
  final Value<int> growthStage;
  final Value<bool> isAlive;
  final Value<DateTime> plantedAt;
  final Value<DateTime?> diedAt;
  final Value<DateTime> lastWateredAt;
  final Value<int> rowid;
  const TreesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.species = const Value.absent(),
    this.growthStage = const Value.absent(),
    this.isAlive = const Value.absent(),
    this.plantedAt = const Value.absent(),
    this.diedAt = const Value.absent(),
    this.lastWateredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreesCompanion.insert({
    required String id,
    required String userId,
    this.sessionId = const Value.absent(),
    required String species,
    this.growthStage = const Value.absent(),
    this.isAlive = const Value.absent(),
    required DateTime plantedAt,
    this.diedAt = const Value.absent(),
    required DateTime lastWateredAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        species = Value(species),
        plantedAt = Value(plantedAt),
        lastWateredAt = Value(lastWateredAt);
  static Insertable<Tree> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? sessionId,
    Expression<String>? species,
    Expression<int>? growthStage,
    Expression<bool>? isAlive,
    Expression<DateTime>? plantedAt,
    Expression<DateTime>? diedAt,
    Expression<DateTime>? lastWateredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (species != null) 'species': species,
      if (growthStage != null) 'growth_stage': growthStage,
      if (isAlive != null) 'is_alive': isAlive,
      if (plantedAt != null) 'planted_at': plantedAt,
      if (diedAt != null) 'died_at': diedAt,
      if (lastWateredAt != null) 'last_watered_at': lastWateredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? sessionId,
      Value<String>? species,
      Value<int>? growthStage,
      Value<bool>? isAlive,
      Value<DateTime>? plantedAt,
      Value<DateTime?>? diedAt,
      Value<DateTime>? lastWateredAt,
      Value<int>? rowid}) {
    return TreesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      species: species ?? this.species,
      growthStage: growthStage ?? this.growthStage,
      isAlive: isAlive ?? this.isAlive,
      plantedAt: plantedAt ?? this.plantedAt,
      diedAt: diedAt ?? this.diedAt,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (growthStage.present) {
      map['growth_stage'] = Variable<int>(growthStage.value);
    }
    if (isAlive.present) {
      map['is_alive'] = Variable<bool>(isAlive.value);
    }
    if (plantedAt.present) {
      map['planted_at'] = Variable<DateTime>(plantedAt.value);
    }
    if (diedAt.present) {
      map['died_at'] = Variable<DateTime>(diedAt.value);
    }
    if (lastWateredAt.present) {
      map['last_watered_at'] = Variable<DateTime>(lastWateredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('species: $species, ')
          ..write('growthStage: $growthStage, ')
          ..write('isAlive: $isAlive, ')
          ..write('plantedAt: $plantedAt, ')
          ..write('diedAt: $diedAt, ')
          ..write('lastWateredAt: $lastWateredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, key, title, description, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<Achievement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String id;
  final String userId;
  final String key;
  final String title;
  final String description;
  final DateTime? unlockedAt;
  const Achievement(
      {required this.id,
      required this.userId,
      required this.key,
      required this.title,
      required this.description,
      this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      userId: Value(userId),
      key: Value(key),
      title: Value(title),
      description: Value(description),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  Achievement copyWith(
          {String? id,
          String? userId,
          String? key,
          String? title,
          String? description,
          Value<DateTime?> unlockedAt = const Value.absent()}) =>
      Achievement(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        key: key ?? this.key,
        title: title ?? this.title,
        description: description ?? this.description,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, key, title, description, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.key == this.key &&
          other.title == this.title &&
          other.description == this.description &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> key;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String userId,
    required String key,
    required String title,
    required String description,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        key = Value(key),
        title = Value(title),
        description = Value(description);
  static Insertable<Achievement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? key,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime?>? unlockedAt,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlacklistEntryTable extends BlacklistEntry
    with TableInfo<$BlacklistEntryTable, BlacklistEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlacklistEntryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [packageName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blacklist_entry';
  @override
  VerificationContext validateIntegrity(Insertable<BlacklistEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  BlacklistEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlacklistEntryData(
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
    );
  }

  @override
  $BlacklistEntryTable createAlias(String alias) {
    return $BlacklistEntryTable(attachedDatabase, alias);
  }
}

class BlacklistEntryData extends DataClass
    implements Insertable<BlacklistEntryData> {
  final String packageName;
  const BlacklistEntryData({required this.packageName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    return map;
  }

  BlacklistEntryCompanion toCompanion(bool nullToAbsent) {
    return BlacklistEntryCompanion(
      packageName: Value(packageName),
    );
  }

  factory BlacklistEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlacklistEntryData(
      packageName: serializer.fromJson<String>(json['packageName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
    };
  }

  BlacklistEntryData copyWith({String? packageName}) => BlacklistEntryData(
        packageName: packageName ?? this.packageName,
      );
  BlacklistEntryData copyWithCompanion(BlacklistEntryCompanion data) {
    return BlacklistEntryData(
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlacklistEntryData(')
          ..write('packageName: $packageName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => packageName.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlacklistEntryData && other.packageName == this.packageName);
}

class BlacklistEntryCompanion extends UpdateCompanion<BlacklistEntryData> {
  final Value<String> packageName;
  final Value<int> rowid;
  const BlacklistEntryCompanion({
    this.packageName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlacklistEntryCompanion.insert({
    required String packageName,
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName);
  static Insertable<BlacklistEntryData> custom({
    Expression<String>? packageName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlacklistEntryCompanion copyWith(
      {Value<String>? packageName, Value<int>? rowid}) {
    return BlacklistEntryCompanion(
      packageName: packageName ?? this.packageName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlacklistEntryCompanion(')
          ..write('packageName: $packageName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TreesTable trees = $TreesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $BlacklistEntryTable blacklistEntry = $BlacklistEntryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, sessions, trees, achievements, blacklistEntry];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  Value<String?> displayName,
  Value<int> streakCount,
  Value<int> longestStreak,
  Value<int> totalFocusSeconds,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String?> displayName,
  Value<int> streakCount,
  Value<int> longestStreak,
  Value<int> totalFocusSeconds,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFocusSeconds => $composableBuilder(
      column: $table.totalFocusSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFocusSeconds => $composableBuilder(
      column: $table.totalFocusSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => column);

  GeneratedColumn<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => column);

  GeneratedColumn<int> get totalFocusSeconds => $composableBuilder(
      column: $table.totalFocusSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<int> streakCount = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<int> totalFocusSeconds = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            displayName: displayName,
            streakCount: streakCount,
            longestStreak: longestStreak,
            totalFocusSeconds: totalFocusSeconds,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> displayName = const Value.absent(),
            Value<int> streakCount = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<int> totalFocusSeconds = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            displayName: displayName,
            streakCount: streakCount,
            longestStreak: longestStreak,
            totalFocusSeconds: totalFocusSeconds,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String userId,
  required String mode,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<int> durationSeconds,
  Value<String?> intention,
  Value<String?> ambientSound,
  required String outcome,
  Value<String?> roomId,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> mode,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int> durationSeconds,
  Value<String?> intention,
  Value<String?> ambientSound,
  Value<String> outcome,
  Value<String?> roomId,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intention => $composableBuilder(
      column: $table.intention, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intention => $composableBuilder(
      column: $table.intention, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomId => $composableBuilder(
      column: $table.roomId, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get intention =>
      $composableBuilder(column: $table.intention, builder: (column) => column);

  GeneratedColumn<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String?> intention = const Value.absent(),
            Value<String?> ambientSound = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<String?> roomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            userId: userId,
            mode: mode,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            intention: intention,
            ambientSound: ambientSound,
            outcome: outcome,
            roomId: roomId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String mode,
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String?> intention = const Value.absent(),
            Value<String?> ambientSound = const Value.absent(),
            required String outcome,
            Value<String?> roomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            userId: userId,
            mode: mode,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            intention: intention,
            ambientSound: ambientSound,
            outcome: outcome,
            roomId: roomId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()>;
typedef $$TreesTableCreateCompanionBuilder = TreesCompanion Function({
  required String id,
  required String userId,
  Value<String?> sessionId,
  required String species,
  Value<int> growthStage,
  Value<bool> isAlive,
  required DateTime plantedAt,
  Value<DateTime?> diedAt,
  required DateTime lastWateredAt,
  Value<int> rowid,
});
typedef $$TreesTableUpdateCompanionBuilder = TreesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> sessionId,
  Value<String> species,
  Value<int> growthStage,
  Value<bool> isAlive,
  Value<DateTime> plantedAt,
  Value<DateTime?> diedAt,
  Value<DateTime> lastWateredAt,
  Value<int> rowid,
});

class $$TreesTableFilterComposer extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAlive => $composableBuilder(
      column: $table.isAlive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plantedAt => $composableBuilder(
      column: $table.plantedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get diedAt => $composableBuilder(
      column: $table.diedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastWateredAt => $composableBuilder(
      column: $table.lastWateredAt, builder: (column) => ColumnFilters(column));
}

class $$TreesTableOrderingComposer
    extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAlive => $composableBuilder(
      column: $table.isAlive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plantedAt => $composableBuilder(
      column: $table.plantedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get diedAt => $composableBuilder(
      column: $table.diedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastWateredAt => $composableBuilder(
      column: $table.lastWateredAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TreesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<int> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => column);

  GeneratedColumn<bool> get isAlive =>
      $composableBuilder(column: $table.isAlive, builder: (column) => column);

  GeneratedColumn<DateTime> get plantedAt =>
      $composableBuilder(column: $table.plantedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get diedAt =>
      $composableBuilder(column: $table.diedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWateredAt => $composableBuilder(
      column: $table.lastWateredAt, builder: (column) => column);
}

class $$TreesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TreesTable,
    Tree,
    $$TreesTableFilterComposer,
    $$TreesTableOrderingComposer,
    $$TreesTableAnnotationComposer,
    $$TreesTableCreateCompanionBuilder,
    $$TreesTableUpdateCompanionBuilder,
    (Tree, BaseReferences<_$AppDatabase, $TreesTable, Tree>),
    Tree,
    PrefetchHooks Function()> {
  $$TreesTableTableManager(_$AppDatabase db, $TreesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<int> growthStage = const Value.absent(),
            Value<bool> isAlive = const Value.absent(),
            Value<DateTime> plantedAt = const Value.absent(),
            Value<DateTime?> diedAt = const Value.absent(),
            Value<DateTime> lastWateredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TreesCompanion(
            id: id,
            userId: userId,
            sessionId: sessionId,
            species: species,
            growthStage: growthStage,
            isAlive: isAlive,
            plantedAt: plantedAt,
            diedAt: diedAt,
            lastWateredAt: lastWateredAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> sessionId = const Value.absent(),
            required String species,
            Value<int> growthStage = const Value.absent(),
            Value<bool> isAlive = const Value.absent(),
            required DateTime plantedAt,
            Value<DateTime?> diedAt = const Value.absent(),
            required DateTime lastWateredAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TreesCompanion.insert(
            id: id,
            userId: userId,
            sessionId: sessionId,
            species: species,
            growthStage: growthStage,
            isAlive: isAlive,
            plantedAt: plantedAt,
            diedAt: diedAt,
            lastWateredAt: lastWateredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TreesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TreesTable,
    Tree,
    $$TreesTableFilterComposer,
    $$TreesTableOrderingComposer,
    $$TreesTableAnnotationComposer,
    $$TreesTableCreateCompanionBuilder,
    $$TreesTableUpdateCompanionBuilder,
    (Tree, BaseReferences<_$AppDatabase, $TreesTable, Tree>),
    Tree,
    PrefetchHooks Function()>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  required String userId,
  required String key,
  required String title,
  required String description,
  Value<DateTime?> unlockedAt,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> key,
  Value<String> title,
  Value<String> description,
  Value<DateTime?> unlockedAt,
  Value<int> rowid,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            userId: userId,
            key: key,
            title: title,
            description: description,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String key,
            required String title,
            required String description,
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            userId: userId,
            key: key,
            title: title,
            description: description,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()>;
typedef $$BlacklistEntryTableCreateCompanionBuilder = BlacklistEntryCompanion
    Function({
  required String packageName,
  Value<int> rowid,
});
typedef $$BlacklistEntryTableUpdateCompanionBuilder = BlacklistEntryCompanion
    Function({
  Value<String> packageName,
  Value<int> rowid,
});

class $$BlacklistEntryTableFilterComposer
    extends Composer<_$AppDatabase, $BlacklistEntryTable> {
  $$BlacklistEntryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnFilters(column));
}

class $$BlacklistEntryTableOrderingComposer
    extends Composer<_$AppDatabase, $BlacklistEntryTable> {
  $$BlacklistEntryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnOrderings(column));
}

class $$BlacklistEntryTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlacklistEntryTable> {
  $$BlacklistEntryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => column);
}

class $$BlacklistEntryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BlacklistEntryTable,
    BlacklistEntryData,
    $$BlacklistEntryTableFilterComposer,
    $$BlacklistEntryTableOrderingComposer,
    $$BlacklistEntryTableAnnotationComposer,
    $$BlacklistEntryTableCreateCompanionBuilder,
    $$BlacklistEntryTableUpdateCompanionBuilder,
    (
      BlacklistEntryData,
      BaseReferences<_$AppDatabase, $BlacklistEntryTable, BlacklistEntryData>
    ),
    BlacklistEntryData,
    PrefetchHooks Function()> {
  $$BlacklistEntryTableTableManager(
      _$AppDatabase db, $BlacklistEntryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlacklistEntryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlacklistEntryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlacklistEntryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> packageName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BlacklistEntryCompanion(
            packageName: packageName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String packageName,
            Value<int> rowid = const Value.absent(),
          }) =>
              BlacklistEntryCompanion.insert(
            packageName: packageName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BlacklistEntryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BlacklistEntryTable,
    BlacklistEntryData,
    $$BlacklistEntryTableFilterComposer,
    $$BlacklistEntryTableOrderingComposer,
    $$BlacklistEntryTableAnnotationComposer,
    $$BlacklistEntryTableCreateCompanionBuilder,
    $$BlacklistEntryTableUpdateCompanionBuilder,
    (
      BlacklistEntryData,
      BaseReferences<_$AppDatabase, $BlacklistEntryTable, BlacklistEntryData>
    ),
    BlacklistEntryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TreesTableTableManager get trees =>
      $$TreesTableTableManager(_db, _db.trees);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$BlacklistEntryTableTableManager get blacklistEntry =>
      $$BlacklistEntryTableTableManager(_db, _db.blacklistEntry);
}
