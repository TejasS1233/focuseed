import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/db/database.dart';
import '../core/db/daos/session_dao.dart';
import '../core/db/daos/journal_dao.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';

final _journalProvider = FutureProvider.family<List<JournalEntry>, String>((ref, userId) {
  final dao = JournalDao(ref.read(databaseProvider));
  return dao.getEntriesByUser(userId);
});

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider);
    final AsyncValue<List<JournalEntry>> entriesAsync = userId != null
        ? ref.watch(_journalProvider(userId))
        : const AsyncLoading();

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Journal', style: AppTypography.display2.copyWith(fontSize: 24)),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong', style: AppTypography.body)),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Icon(Icons.book_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 24),
                    Text('No journal entries yet', style: AppTypography.display2),
                    const SizedBox(height: 8),
                    Text('Reflect on your sessions to see them here',
                      style: AppTypography.body.copyWith(color: context.textMuted)),
                  ],
                ),
              ),
            );
          }

          final grouped = _groupByDate(entries);
          return RefreshIndicator(
            onRefresh: () async {
              if (userId != null) ref.invalidate(_journalProvider(userId));
            },
            color: AppColors.primary,
            backgroundColor: context.surfaceElevated,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: grouped.length,
              itemBuilder: (_, i) => _JournalDateGroup(
                date: grouped[i].key,
                entries: grouped[i].value,
                index: i,
              ),
            ),
          );
        },
      ),
    );
  }

  List<MapEntry<DateTime, List<JournalEntry>>> _groupByDate(List<JournalEntry> entries) {
    final map = <DateTime, List<JournalEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sorted;
  }
}

class _JournalDateGroup extends StatefulWidget {
  final DateTime date;
  final List<JournalEntry> entries;
  final int index;

  const _JournalDateGroup({
    required this.date,
    required this.entries,
    required this.index,
  });

  @override
  State<_JournalDateGroup> createState() => _JournalDateGroupState();
}

class _JournalDateGroupState extends State<_JournalDateGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(widget.date).inDays;

    String label;
    if (diff == 0) {
      label = 'Today';
    } else if (diff == 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMMM d, yyyy').format(widget.date);
    }

    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Text(label, style: AppTypography.heading2.copyWith(color: context.textPrimary)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text('${widget.entries.length}', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          ...widget.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _JournalEntryCard(entry: e),
          )),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends ConsumerWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionForEntryProvider(entry.sessionId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.25),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: context.textMuted),
              const SizedBox(width: 4),
              Text(
                DateFormat('h:mm a').format(entry.createdAt),
                style: AppTypography.caption.copyWith(color: context.textMuted),
              ),
              const Spacer(),
              _RatingStars(rating: entry.rating),
            ],
          ),
          const SizedBox(height: 10),
          sessionsAsync.when(
            data: (session) {
              if (session == null) return const SizedBox.shrink();
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: session.mode == 'hard'
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      session.mode == 'hard' ? 'HARD' : 'SOFT',
                      style: AppTypography.caption.copyWith(
                        color: session.mode == 'hard' ? AppColors.error : AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(session.durationSeconds),
                    style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                  ),
                  if (session.intention != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"${session.intention}"',
                        style: AppTypography.caption.copyWith(
                          color: context.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (entry.content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surfaceHighlight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                entry.content,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final _sessionForEntryProvider = FutureProvider.family<Session?, String>((ref, sessionId) {
  final dao = SessionDao(ref.read(databaseProvider));
  return dao.getSession(sessionId);
});

class _RatingStars extends StatelessWidget {
  final int rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: i < rating ? AppColors.secondary : context.textMuted,
        );
      }),
    );
  }
}
