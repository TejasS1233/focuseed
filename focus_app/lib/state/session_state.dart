import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lock_service.dart';
import '../core/services/audio_mixer_service.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import '../core/db/daos/achievement_dao.dart';
import '../core/services/widget_service.dart';
import 'app_state.dart';

enum SessionStatus { idle, running, paused, completed, abandoned }

class SessionState {
  final String? sessionId;
  final SessionStatus status;
  final int elapsedSeconds;
  final int? setDurationSeconds;
  final String mode;
  final String? intention;
  final Map<String, double> mixConfig;
  final String? userId;

  SessionState({
    this.sessionId,
    this.status = SessionStatus.idle,
    this.elapsedSeconds = 0,
    this.setDurationSeconds,
    this.mode = 'soft',
    this.intention,
    this.mixConfig = const {},
    this.userId,
  });

  SessionState copyWith({
    String? sessionId,
    SessionStatus? status,
    int? elapsedSeconds,
    int? setDurationSeconds,
    String? mode,
    String? intention,
    Map<String, double>? mixConfig,
    String? userId,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      mode: mode ?? this.mode,
      intention: intention ?? this.intention,
      mixConfig: mixConfig ?? this.mixConfig,
      userId: userId ?? this.userId,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  Timer? _timer;
  int _startSeconds = 0;
  final AudioMixerService _mixer = AudioMixerService();
  final LockService _lock = LockService();
  bool _mixerReady = false;

  @override
  SessionState build() => SessionState();

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _ensureMixer() async {
    if (!_mixerReady) {
      await _mixer.init();
      _mixerReady = true;
    }
  }

  Future<void> startSession({
    required String mode,
    required int durationMinutes,
    String? intention,
    Map<String, double>? mixConfig,
  }) async {
    await _ensureMixer();
    final userId = ref.read(userProvider);
    final mix = mixConfig ?? {};
    state = SessionState(
      sessionId: _generateId(),
      status: SessionStatus.running,
      mode: mode,
      setDurationSeconds: durationMinutes * 60,
      intention: intention,
      mixConfig: mix,
      userId: userId,
    );
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: now - _startSeconds);
    });

    await _lock.startLock(
      durationMinutes: durationMinutes,
      hardLock: mode == 'hard',
    );
    if (mix.isNotEmpty) {
      await _mixer.applyMix(mix);
    }
  }

  void pauseSession() {
    _timer?.cancel();
    _mixer.pauseAll();
    state = state.copyWith(status: SessionStatus.paused);
  }

  void resumeSession() {
    final pausedElapsed = state.elapsedSeconds;
    _startSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - pausedElapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: now - _startSeconds);
    });
    _mixer.playAll();
    state = state.copyWith(status: SessionStatus.running);
  }

  Future<void> endSession({required bool completed}) async {
    _timer?.cancel();
    await _lock.stopLock();
    _mixer.stopAll();
    _persistSession(completed);
    state = state.copyWith(
      status: completed ? SessionStatus.completed : SessionStatus.abandoned,
    );
  }

  void _persistSession(bool completed) {
    final userId = ref.read(userProvider);
    final sessionId = state.sessionId;
    if (userId == null || sessionId == null) return;

    final db = ref.read(databaseProvider);
    final dao = SessionDao(db);
    final now = DateTime.now();
    final mixStr = AudioMixerService.isEmptyMix(state.mixConfig)
        ? null
        : AudioMixerService.serializeMix(state.mixConfig);
    dao.insertSession(Session(
      id: sessionId,
      userId: userId,
      mode: state.mode,
      startTime: now.subtract(Duration(seconds: state.elapsedSeconds)),
      endTime: now,
      durationSeconds: state.elapsedSeconds,
      intention: state.intention,
      ambientSound: mixStr,
      outcome: completed ? 'completed' : 'abandoned',
      roomId: null,
    ));

    if (completed) {
      AchievementDao(db).checkAndUnlock(userId);
      _updateWidget(db, userId);
    }
  }

  Future<void> startSessionWithBlacklist({
    required String mode,
    required int durationMinutes,
    String? intention,
    Map<String, double>? mixConfig,
    List<String> blacklist = const [],
  }) async {
    await _ensureMixer();
    final userId = ref.read(userProvider);
    final mix = mixConfig ?? {};
    state = SessionState(
      sessionId: _generateId(),
      status: SessionStatus.running,
      mode: mode,
      setDurationSeconds: durationMinutes * 60,
      intention: intention,
      mixConfig: mix,
      userId: userId,
    );
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: now - _startSeconds);
    });
    if (mode == 'hard') {
      await _lock.startLock(
        durationMinutes: durationMinutes,
        hardLock: true,
        blacklist: blacklist,
      );
    }
    if (mix.isNotEmpty) {
      await _mixer.applyMix(mix);
    }
  }

  Future<void> _updateWidget(AppDatabase db, String userId) async {
    final dao = SessionDao(db);
    final streak = await dao.getCurrentStreak(userId);
    final todaySeconds = await dao.getTodaySeconds(userId);
    await WidgetService.updateWidget(
      streak: streak,
      todayMinutes: todaySeconds ~/ 60,
    );
  }

  void onAppLifecycleChange(AppLifecycleState lifecycleState) {
    if (state.status != SessionStatus.running) return;
    if (lifecycleState == AppLifecycleState.paused) {
      if (state.mode == 'hard') {
        _timer?.cancel();
        _mixer.pauseAll();
        state = state.copyWith(status: SessionStatus.paused);
      } else {
        _timer?.cancel();
      }
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
