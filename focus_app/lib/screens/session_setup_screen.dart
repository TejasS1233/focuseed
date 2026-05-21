import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import '../state/blacklist_state.dart';
import '../core/services/audio_mixer_service.dart';
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
  final _intentionController = TextEditingController();
  final AudioMixerService _previewMixer = AudioMixerService();
  bool _mixerInitialized = false;
  bool _mixerExpanded = false;
  late Map<String, double> _mixConfig;

  String? _selectedTag;
  int _breakMinutes = 0;

  static const _tags = ['Work', 'Study', 'Creative', 'Reading', 'Exercise', 'Deep Work'];
  static const _intervals = [
    ('Pomodoro', 25, 5),
    ('Focus 50/10', 50, 10),
    ('Custom', null, null),
  ];
  bool _customInterval = false;

  @override
  void initState() {
    super.initState();
    _mixConfig = {
      for (final t in AudioMixerService.tracks) t.key: 0.0,
    };
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _previewMixer.stopAll();
    _previewMixer.dispose();
    super.dispose();
  }

  Future<void> _initMixer() async {
    if (_mixerInitialized) return;
    await _previewMixer.init();
    _mixerInitialized = true;
  }

  Future<void> _onVolumeChanged(String key, double volume) async {
    setState(() => _mixConfig[key] = volume);
    if (!_mixerInitialized) await _initMixer();
    await _previewMixer.setVolume(key, volume);
  }

  void _applyInterval(int focusMin, int breakMin) {
    setState(() {
      _customInterval = false;
      _durationMinutes = focusMin;
      _breakMinutes = breakMin;
    });
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    _previewMixer.stopAll();
    _intention = _intentionController.text.trim();
    if (_intention!.isEmpty) _intention = null;

    if (_mode == 'hard') {
      final canProceed = await PermissionCheckDialog.canStartHardLock(context);
      if (!canProceed) return;
    }

    final mix = Map<String, double>.from(_mixConfig);
    mix.removeWhere((_, v) => v <= 0);

    final blacklisted = await ref.read(blacklistProvider.notifier).load();

    ref.read(sessionProvider.notifier).startSessionWithBlacklist(
      mode: _mode,
      durationMinutes: _durationMinutes,
      intention: _intention,
      mixConfig: mix,
      blacklist: _mode == 'hard' ? blacklisted : [],
      tag: _selectedTag,
      breakDurationSeconds: _breakMinutes * 60,
    );

    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => const FocusScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final anyActive = _mixConfig.values.any((v) => v > 0);
    final activeCount = _mixConfig.values.where((v) => v > 0).length;

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
            Text('Tag', style: AppTypography.heading2),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [null, ..._tags].map((t) => GestureDetector(
                onTap: () => setState(() => _selectedTag = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedTag == t
                        ? AppColors.primary.withOpacity(0.15)
                        : context.surfaceElevated.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: _selectedTag == t
                          ? AppColors.primary.withOpacity(0.4)
                          : context.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(t ?? 'Any', style: AppTypography.label.copyWith(
                    color: _selectedTag == t ? AppColors.primary : context.textMuted,
                  )),
                ),
              )).toList(),
            ),
            const SizedBox(height: 28),
            Text('Timer Interval', style: AppTypography.heading2),
            const SizedBox(height: 10),
            Row(
              children: _intervals.map((entry) {
                final label = entry.$1;
                final isActive = !_customInterval && _durationMinutes == entry.$2;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: entry == _intervals.first ? 0 : 4,
                      right: entry == _intervals.last ? 0 : 4,
                    ),
                    child: GestureDetector(
                      onTap: entry.$2 != null
                          ? () => _applyInterval(entry.$2!, entry.$3!)
                          : () => setState(() => _customInterval = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.1)
                              : context.surfaceElevated.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isActive ? AppColors.primary.withOpacity(0.4) : context.border,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(label, style: AppTypography.caption.copyWith(
                              color: isActive ? AppColors.primary : context.textPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                            if (entry.$2 != null) ...[
                              const SizedBox(height: 2),
                              Text('${entry.$2}/${entry.$3}', style: AppTypography.caption.copyWith(
                                color: context.textMuted, fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_customInterval) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Focus: ${_durationMinutes}m', style: AppTypography.caption.copyWith(color: context.textMuted)),
                        Slider(
                          value: _durationMinutes.toDouble(),
                          min: 5, max: 120, divisions: 23,
                          onChanged: (v) => setState(() => _durationMinutes = v.round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Break: ${_breakMinutes}m', style: AppTypography.caption.copyWith(color: context.textMuted)),
                        Slider(
                          value: _breakMinutes.toDouble(),
                          min: 0, max: 30, divisions: 6,
                          onChanged: (v) => setState(() => _breakMinutes = v.round()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => setState(() => _mixerExpanded = !_mixerExpanded),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 18, color: context.textSecondary),
                  const SizedBox(width: 8),
                  Text('Sound Mixer', style: AppTypography.heading2),
                  const Spacer(),
                  if (anyActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('$activeCount active',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary, fontSize: 11)),
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _mixerExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, size: 20, color: context.textMuted),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _SoundMixerPanel(
                  mixConfig: _mixConfig,
                  onVolumeChanged: _onVolumeChanged,
                ),
              ),
              crossFadeState: _mixerExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
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

class _SoundMixerPanel extends StatelessWidget {
  final Map<String, double> mixConfig;
  final Function(String key, double volume) onVolumeChanged;

  const _SoundMixerPanel({
    required this.mixConfig,
    required this.onVolumeChanged,
  });

  static const _trackIcons = {
    'rain': Icons.water_drop,
    'lofi': Icons.headphones,
    'whitenoise': Icons.graphic_eq,
    'forest': Icons.forest,
    'drone': Icons.waves,
  };

  static const _trackColors = {
    'rain': Color(0xFF4FC3F7),
    'lofi': Color(0xFFAB47BC),
    'whitenoise': Color(0xFF78909C),
    'forest': Color(0xFF66BB6A),
    'drone': Color(0xFF42A5F5),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (final track in AudioMixerService.tracks) ...[
            if (track != AudioMixerService.tracks.first)
              const Divider(height: 20),
            _TrackSlider(
              trackKey: track.key,
              label: track.label,
              icon: _trackIcons[track.key] ?? Icons.music_note,
              color: _trackColors[track.key] ?? AppColors.primary,
              volume: mixConfig[track.key] ?? 0,
              onChanged: (v) => onVolumeChanged(track.key, v),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackSlider extends StatelessWidget {
  final String trackKey;
  final String label;
  final IconData icon;
  final Color color;
  final double volume;
  final ValueChanged<double> onChanged;

  const _TrackSlider({
    required this.trackKey,
    required this.label,
    required this.icon,
    required this.color,
    required this.volume,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = volume > 0;
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18,
            color: active ? color : context.textMuted),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 72,
          child: Text(label,
            style: AppTypography.bodySmall.copyWith(
              color: active ? context.textPrimary : context.textMuted,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            )),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
              activeTrackColor: color,
              inactiveTrackColor: context.border,
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
            ),
            child: Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('${(volume * 100).round()}%',
            style: AppTypography.caption.copyWith(
              color: active ? color : context.textMuted,
              fontSize: 11,
            )),
        ),
      ],
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
