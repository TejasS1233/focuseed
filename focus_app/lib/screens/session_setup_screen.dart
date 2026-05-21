import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import '../state/blacklist_state.dart';
import '../theme/theme.dart';
import 'focus_screen.dart';
import 'permission_check_screen.dart';

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  String _mode = 'soft';
  String? _intention;
  int _durationMinutes = 30;
  String? _ambientSound;
  final _intentionController = TextEditingController();

  static const _soundOptions = [
    ('None', null),
    ('Rain', 'rain'),
    ('Lo-fi', 'lofi'),
    ('White Noise', 'whitenoise'),
  ];

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    _intention = _intentionController.text.trim();
    if (_intention!.isEmpty) _intention = null;

    if (_mode == 'hard') {
      final canProceed = await PermissionCheckDialog.canStartHardLock(context);
      if (!canProceed) return;
    }

    final blacklistState = ref.read(blacklistProvider);
    final blacklisted = blacklistState.blacklistedPackages;

    ref.read(sessionProvider.notifier).startSessionWithBlacklist(
      mode: _mode,
      durationMinutes: _durationMinutes,
      intention: _intention,
      ambientSound: _ambientSound,
      blacklist: _mode == 'hard' ? blacklisted : [],
    );

    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const FocusScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Session', style: AppTypography.display2.copyWith(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Mode', style: AppTypography.heading2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ModeCard(
                  label: 'Soft Focus',
                  icon: Icons.blur_on,
                  desc: 'Flexible • Can stop anytime',
                  selected: _mode == 'soft',
                  color: AppColors.primary,
                  onTap: () => setState(() => _mode = 'soft'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ModeCard(
                  label: 'Hard Lock',
                  icon: Icons.lock,
                  desc: 'Commit • Cannot stop early',
                  selected: _mode == 'hard',
                  color: AppColors.error,
                  onTap: () => setState(() => _mode = 'hard'),
                )),
              ],
            ),
            const SizedBox(height: 28),
            Text('Set Intention', style: AppTypography.heading2),
            const SizedBox(height: 12),
            TextField(
              controller: _intentionController,
              decoration: InputDecoration(
                hintText: 'What do you want to focus on?',
                prefixIcon: Icon(Icons.edit_outlined, size: 18, color: context.textMuted),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration', style: AppTypography.heading2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text('$_durationMinutes min',
                    style: AppTypography.label.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_durationMinutes min',
              onChanged: (v) => setState(() => _durationMinutes = v.round()),
            ),
            const SizedBox(height: 28),
            Text('Ambient Sound', style: AppTypography.heading2),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _soundOptions.map((opt) {
                final selected = _ambientSound == opt.$2;
                return GestureDetector(
                  onTap: () => setState(() => _ambientSound = opt.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withOpacity(0.12) : context.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: selected ? AppColors.primary : context.border,
                        width: selected ? 1 : 0.5,
                      ),
                    ),
                    child: Text(
                      opt.$1,
                      style: AppTypography.bodySmall.copyWith(
                        color: selected ? AppColors.primary : context.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.glow(AppColors.primary, intensity: 0.4),
                ),
                child: ElevatedButton(
                  onPressed: _start,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_mode == 'hard' ? Icons.lock : Icons.blur_on, size: 18),
                      const SizedBox(width: 8),
                      Text(_mode == 'hard' ? 'Lock In' : 'Begin Focus'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label, desc;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label, required this.desc, required this.icon,
    required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.08)
              : context.surfaceElevated.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? color : context.border,
            width: selected ? 1 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12)]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : context.textMuted, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.heading3.copyWith(
              color: selected ? context.textPrimary : context.textSecondary,
            )),
            const SizedBox(height: 4),
            Text(desc, style: AppTypography.caption.copyWith(
              color: selected ? context.textSecondary : context.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
