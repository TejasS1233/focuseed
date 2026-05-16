import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import '../theme/theme.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session.status == SessionStatus.completed) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: UISpacing.md),
              const Text('Session Complete!',
                style: UITypography.heading1),
              const SizedBox(height: UISpacing.sm),
              Text('You focused for ${_formatTime(session.elapsedSeconds)}',
                style: UITypography.body),
              const SizedBox(height: UISpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.primary,
                  foregroundColor: UIColors.white,
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    if (session.status == SessionStatus.abandoned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.popUntil(context, (r) => r.isFirst);
      });
      return const SizedBox.shrink();
    }

    final remaining = session.setDurationSeconds != null
        ? session.setDurationSeconds! - session.elapsedSeconds
        : 0;
    final remainingFormatted = _formatTime(remaining > 0 ? remaining : 0);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UISpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  session.mode == 'hard' ? Icons.lock : Icons.blur_on,
                  size: 24,
                  color: session.mode == 'hard'
                      ? UIColors.error : UIColors.primary,
                ),
                const SizedBox(width: 8),
                Text(session.mode == 'hard' ? 'HARD LOCK' : 'SOFT FOCUS',
                  style: UITypography.caption.copyWith(
                    color: session.mode == 'hard'
                        ? UIColors.error : UIColors.primary,
                    letterSpacing: 2,
                  )),
              ],
            ),
            const SizedBox(height: UISpacing.xl),
            Text(remainingFormatted,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              )),
            if (session.intention != null) ...[
              const SizedBox(height: UISpacing.sm),
              Text('"${session.intention}"',
                style: UITypography.body.copyWith(
                  color: UIColors.gray500,
                  fontStyle: FontStyle.italic,
                )),
            ],
            const SizedBox(height: UISpacing.lg),
            Icon(Icons.park, size: 64, color: Colors.green[300]),
            const SizedBox(height: UISpacing.xl),
            if (session.status == SessionStatus.running) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).pauseSession();
                  },
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: UISpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(sessionProvider.notifier)
                        .endSession(completed: false);
                  },
                  child: Text('End Session',
                    style: TextStyle(color: UIColors.error)),
                ),
              ),
            ] else if (session.status == SessionStatus.paused) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).resumeSession();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.primary,
                    foregroundColor: UIColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: UISpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(sessionProvider.notifier)
                        .endSession(completed: false);
                  },
                  child: Text('End Session',
                    style: TextStyle(color: UIColors.error)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
