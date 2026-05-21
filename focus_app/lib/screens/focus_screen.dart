import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import '../state/app_state.dart';
import '../core/db/database.dart';
import '../core/db/daos/journal_dao.dart';
import '../theme/theme.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with WidgetsBindingObserver {
  bool _promptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _showReflectionPrompt(String sessionId) async {
    if (_promptShown) return;
    _promptShown = true;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _ReflectionSheet.show(context, sessionId);
    if (!mounted || !context.mounted) return;
    _maybeShowBreakReminder();
  }

  void _maybeShowBreakReminder() {
    final session = ref.read(sessionProvider);
    if (session.breakDurationSeconds <= 0 || !context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => _BreakReminderDialog(breakSeconds: session.breakDurationSeconds),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(sessionProvider.notifier).onAppLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session.status == SessionStatus.completed) {
      final sessionId = session.sessionId;
      if (sessionId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showReflectionPrompt(sessionId);
        });
      }
      return Scaffold(
        body: Container(
          decoration: context.gradientBg,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.5),
                    ),
                    child: const Icon(Icons.check_circle, size: 52, color: AppColors.primary),
                  ),
                  const SizedBox(height: 28),
                  Text('Session Complete!', style: AppTypography.display1),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceElevated.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('You focused for ${_formatTime(session.elapsedSeconds)}',
                      style: AppTypography.body.copyWith(color: context.textMuted)),
                  ),
                  const SizedBox(height: 12),
                  Text('🌱 A new tree is growing!', style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Back to Garden'),
                    ),
                  ),
                ],
              ),
            ),
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
    final progress = session.setDurationSeconds != null && session.setDurationSeconds! > 0
        ? (session.elapsedSeconds / session.setDurationSeconds!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: Container(
        decoration: context.gradientBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Mode badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: session.mode == 'hard'
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: session.mode == 'hard'
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        session.mode == 'hard' ? Icons.lock : Icons.blur_on,
                        size: 14,
                        color: session.mode == 'hard' ? AppColors.error : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.mode == 'hard' ? 'HARD LOCK' : 'SOFT FOCUS',
                        style: AppTypography.label.copyWith(
                          color: session.mode == 'hard' ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                // Circular timer
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(260, 260),
                        painter: _TimerRingPainter(
                          progress: progress,
                          color: session.mode == 'hard' ? AppColors.error : AppColors.primary,
                          trackColor: context.border,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(remainingFormatted, style: AppTypography.timer),
                          if (session.intention != null) ...[
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 200,
                              child: Text(
                                '"${session.intention}"',
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                // Tree indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surfaceElevated.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: context.border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌱', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text('Growing...', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Controls
                if (session.status == SessionStatus.running) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(sessionProvider.notifier).pauseSession();
                    },
                      icon: const Icon(Icons.pause_rounded, size: 20),
                      label: const Text('Pause'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: context.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(sessionProvider.notifier).endSession(completed: false);
                      },
                      icon: const Icon(Icons.stop_rounded, size: 18),
                      label: Text('End Session',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                    ),
                  ),
                ] else if (session.status == SessionStatus.paused) ...[
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.4),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(sessionProvider.notifier).resumeSession();
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text('Resume'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(sessionProvider.notifier).endSession(completed: false);
                      },
                      icon: const Icon(Icons.stop_rounded, size: 18),
                      label: Text('End Session',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
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

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    this.trackColor = const Color(0xFF2A2A45),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 4.0;

    // Background ring
    final bgPaint = Paint()
      ..color = trackColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow dot at the end
    if (progress > 0 && progress < 1) {
      final dotAngle = -math.pi / 2 + sweepAngle;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);

      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 8, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
    oldDelegate.progress != progress;
}

class _ReflectionSheet extends StatefulWidget {
  final String sessionId;

  const _ReflectionSheet({required this.sessionId});

  static Future<void> show(BuildContext context, String sessionId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReflectionSheet(sessionId: sessionId),
    );
  }

  @override
  State<_ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<_ReflectionSheet> {
  int _rating = 3;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = JournalEntry(
      id: id,
      userId: '',
      sessionId: widget.sessionId,
      rating: _rating,
      content: _controller.text.trim(),
      mood: null,
      createdAt: DateTime.now(),
    );

    final container = ProviderScope.containerOf(context);
    final db = container.read(databaseProvider);
    final dao = JournalDao(db);
    final userId = container.read(userProvider);
    if (userId != null) {
      await dao.insertEntry(entry.copyWith(userId: userId));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.border.withOpacity(0.4), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: 24 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('How was your focus?', style: AppTypography.display2),
            const SizedBox(height: 6),
            Text('Reflect on this session', style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedScale(
                        scale: filled ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 36,
                          color: filled ? AppColors.secondary : context.textMuted.withOpacity(0.4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 3,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: 'What went well? Any thoughts...',
                hintStyle: AppTypography.bodySmall.copyWith(color: context.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: context.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: context.border.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                filled: true,
                fillColor: context.surfaceHighlight.withOpacity(0.1),
                contentPadding: const EdgeInsets.all(14),
                counterStyle: AppTypography.caption.copyWith(color: context.textMuted),
              ),
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Skip', style: AppTypography.body.copyWith(color: context.textMuted)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Reflection'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakReminderDialog extends StatefulWidget {
  final int breakSeconds;
  const _BreakReminderDialog({required this.breakSeconds});

  @override
  State<_BreakReminderDialog> createState() => _BreakReminderDialogState();
}

class _BreakReminderDialogState extends State<_BreakReminderDialog> with SingleTickerProviderStateMixin {
  late int _remaining;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.breakSeconds;
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _remaining--);
      return _remaining > 0 && mounted;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = _remaining ~/ 60;
    final sec = _remaining % 60;
    return AlertDialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(animation: _pulseController, builder: (context, _) {
            return Transform.scale(
              scale: 0.85 + 0.15 * _pulseController.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(Icons.self_improvement, size: 48, color: AppColors.secondary),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('Break Time', style: AppTypography.display2),
          const SizedBox(height: 8),
          Text('Take a breather', style: AppTypography.body.copyWith(color: context.textMuted)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text('${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
              style: AppTypography.timer.copyWith(fontSize: 32, color: AppColors.secondary)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
