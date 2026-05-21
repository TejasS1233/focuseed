import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lock_service.dart';
import '../core/services/audio_mixer_service.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import '../core/db/daos/achievement_dao.dart';
import '../core/services/widget_service.dart';
import '../core/services/notification_service.dart';
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
  final String? tag;
  final int breakDurationSeconds;
  final int focusScore;

  SessionState({
    this.sessionId,
    this.status = SessionStatus.idle,
    this.elapsedSeconds = 0,
    this.setDurationSeconds,
    this.mode = 'soft',
    this.intention,
    this.mixConfig = const {},
    this.userId,
    this.tag,
    this.breakDurationSeconds = 0,
    this.focusScore = 0,
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
    String? tag,
    int? breakDurationSeconds,
    int? focusScore,
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
      tag: tag ?? this.tag,
      breakDurationSeconds: breakDurationSeconds ?? this.breakDurationSeconds,
      focusScore: focusScore ?? this.focusScore,
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
    String? tag,
    int breakDurationSeconds = 0,
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
      tag: tag,
      breakDurationSeconds: breakDurationSeconds,
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

  void _persistSession(bool completed) async {
    final userId = ref.read(userProvider);
    final sessionId = state.sessionId;
    if (userId == null || sessionId == null) return;

    final db = ref.read(databaseProvider);
    final dao = SessionDao(db);
    final now = DateTime.now();
    final mixStr = AudioMixerService.isEmptyMix(state.mixConfig)
        ? null
        : AudioMixerService.serializeMix(state.mixConfig);

    final score = completed ? await dao.getFocusScore(userId) : 0;

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
      tag: state.tag,
      focusScore: completed ? score : null,
      breakDuration: state.breakDurationSeconds > 0 ? state.breakDurationSeconds : null,
    ));

    state = state.copyWith(focusScore: score);

    if (completed) {
      AchievementDao(db).checkAndUnlock(userId);
      _updateWidget(db, userId);
      _showSessionNotification();
      _checkBreakReminder();
    }
  }

  void _showSessionNotification() {
    final title = state.intention != null
        ? 'Session complete: "${state.intention}"'
        : 'Session complete!';
    NotificationService.showSessionComplete(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: 'You focused for ${_formatTime(state.elapsedSeconds)}',
    );
  }

  void _checkBreakReminder() {
    if (state.breakDurationSeconds <= 0) return;
    Future.delayed(Duration(seconds: state.breakDurationSeconds), () {
      NotificationService.showBreakReminder(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Time for a break!',
        body: 'Your ${_formatTime(state.breakDurationSeconds)} break is over. Ready to focus again?',
      );
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  Future<void> startSessionWithBlacklist({
    required String mode,
    required int durationMinutes,
    String? intention,
    Map<String, double>? mixConfig,
    List<String> blacklist = const [],
    String? tag,
    int breakDurationSeconds = 0,
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
      tag: tag,
      breakDurationSeconds: breakDurationSeconds,
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
