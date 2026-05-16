import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lock_service.dart';
import '../core/services/audio_service.dart';
enum SessionStatus { idle, running, paused, completed, abandoned }

class SessionState {
  final String? sessionId;
  final SessionStatus status;
  final int elapsedSeconds;
  final int? setDurationSeconds;
  final String mode;
  final String? intention;
  final String? ambientSound;

  SessionState({
    this.sessionId,
    this.status = SessionStatus.idle,
    this.elapsedSeconds = 0,
    this.setDurationSeconds,
    this.mode = 'soft',
    this.intention,
    this.ambientSound,
  });

  SessionState copyWith({
    String? sessionId,
    SessionStatus? status,
    int? elapsedSeconds,
    int? setDurationSeconds,
    String? mode,
    String? intention,
    String? ambientSound,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      mode: mode ?? this.mode,
      intention: intention ?? this.intention,
      ambientSound: ambientSound ?? this.ambientSound,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  Timer? _timer;
  int _startSeconds = 0;

  @override
  SessionState build() => SessionState();

  void startSession({
    required String mode,
    required int durationMinutes,
    String? intention,
    String? ambientSound,
  }) {
    state = SessionState(
      status: SessionStatus.running,
      mode: mode,
      setDurationSeconds: durationMinutes * 60,
      intention: intention,
      ambientSound: ambientSound,
    );
    _startSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: now - _startSeconds);
    });

    if (mode == 'hard') {
      LockService().startLock(durationMinutes: durationMinutes);
    }
    if (ambientSound != null) {
      AudioService().play(ambientSound);
    }
  }

  void pauseSession() {
    _timer?.cancel();
    AudioService().pause();
    state = state.copyWith(status: SessionStatus.paused);
  }

  void resumeSession() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      state = state.copyWith(elapsedSeconds: now - _startSeconds);
    });
    if (state.ambientSound != null) {
      AudioService().play(state.ambientSound!);
    }
    state = state.copyWith(status: SessionStatus.running);
  }

  Future<void> endSession({required bool completed}) async {
    _timer?.cancel();
    if (state.mode == 'hard') {
      await LockService().stopLock();
    }
    AudioService().stop();
    state = state.copyWith(
      status: completed ? SessionStatus.completed : SessionStatus.abandoned,
    );
  }

}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
