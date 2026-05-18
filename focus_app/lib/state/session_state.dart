import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lock_service.dart';
import '../core/services/audio_service.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import 'app_state.dart';

enum SessionStatus { idle, running, paused, completed, abandoned }

class SessionState {
  final String? sessionId;
  final SessionStatus status;
  final int elapsedSeconds;
  final int? setDurationSeconds;
  final String mode;
  final String? intention;
  final String? ambientSound;
  final String? userId;

  SessionState({
    this.sessionId,
    this.status = SessionStatus.idle,
    this.elapsedSeconds = 0,
    this.setDurationSeconds,
    this.mode = 'soft',
    this.intention,
    this.ambientSound,
    this.userId,
  });

  SessionState copyWith({
    String? sessionId,
    SessionStatus? status,
    int? elapsedSeconds,
    int? setDurationSeconds,
    String? mode,
    String? intention,
    String? ambientSound,
    String? userId,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      mode: mode ?? this.mode,
      intention: intention ?? this.intention,
      ambientSound: ambientSound ?? this.ambientSound,
      userId: userId ?? this.userId,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  Timer? _timer;
  int _startSeconds = 0;
  int _pausedElapsed = 0;

  @override
  SessionState build() => SessionState();

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> startSession({
    required String mode,
    required int durationMinutes,
    String? intention,
    String? ambientSound,
  }) async {
    final userId = ref.read(userProvider);
    state = SessionState(
      sessionId: _generateId(),
      status: SessionStatus.running,
      mode: mode,
      setDurationSeconds: durationMinutes * 60,
      intention: intention,
      ambientSound: ambientSound,
      userId: userId,
    );
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _startTimer();

    await LockService().startLock(
      durationMinutes: durationMinutes,
      hardLock: mode == 'hard',
    );
    if (ambientSound != null) {
      AudioService().play(ambientSound);
    }
  }

  void pauseSession() {
    _timer?.cancel();
    _pausedElapsed = state.elapsedSeconds;
    AudioService().pause();
    state = state.copyWith(status: SessionStatus.paused);
  }

  void resumeSession() {
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _startTimer();
    if (state.ambientSound != null) {
      AudioService().play(state.ambientSound!);
    }
    state = state.copyWith(status: SessionStatus.running);
  }

  void endSession({required bool completed}) {
    _timer?.cancel();
    if (state.mode == 'hard') {
      LockService().stopLock();
    }
    AudioService().stop();
    _persistSession(completed);
    state = state.copyWith(
      status: completed ? SessionStatus.completed : SessionStatus.abandoned,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: _pausedElapsed + (now - _startSeconds));
    });
  }

  void _persistSession(bool completed) {
    final userId = ref.read(userProvider);
    final sessionId = state.sessionId;
    if (userId == null || sessionId == null) return;

    final dao = SessionDao(ref.read(databaseProvider));
    final now = DateTime.now();
    dao.insertSession(Session(
      id: sessionId,
      userId: userId,
      mode: state.mode,
      startTime: now.subtract(Duration(seconds: state.elapsedSeconds)),
      endTime: now,
      durationSeconds: state.elapsedSeconds,
      intention: state.intention,
      ambientSound: state.ambientSound,
      outcome: completed ? 'completed' : 'abandoned',
      roomId: null,
    ));
  }

  Future<void> startSessionWithBlacklist({
    required String mode,
    required int durationMinutes,
    String? intention,
    String? ambientSound,
    List<String> blacklist = const [],
  }) async {
    final userId = ref.read(userProvider);
    state = SessionState(
      sessionId: _generateId(),
      status: SessionStatus.running,
      mode: mode,
      setDurationSeconds: durationMinutes * 60,
      intention: intention,
      ambientSound: ambientSound,
      userId: userId,
    );
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _startTimer();
    if (mode == 'hard') {
      await LockService().startLock(
        durationMinutes: durationMinutes,
        hardLock: true,
        blacklist: blacklist,
      );
    }
    if (ambientSound != null) {
      AudioService().play(ambientSound);
    }
  }

  void onAppLifecycleChange(AppLifecycleState lifecycleState) {
    if (state.status != SessionStatus.running) return;
    if (lifecycleState == AppLifecycleState.paused) {
      _timer?.cancel();
    }
    if (lifecycleState == AppLifecycleState.resumed && state.mode == 'hard') {
      endSession(completed: false);
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
