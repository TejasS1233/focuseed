import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('New Session')),
      body: Padding(
        padding: const EdgeInsets.all(UISpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mode', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'Soft Focus',
                    icon: Icons.blur_on,
                    desc: 'Can stop anytime',
                    selected: _mode == 'soft',
                    onTap: () => setState(() => _mode = 'soft'),
                  ),
                ),
                const SizedBox(width: UISpacing.sm),
                Expanded(
                  child: _ModeButton(
                    label: 'Hard Lock',
                    icon: Icons.lock,
                    desc: 'Cannot stop early',
                    selected: _mode == 'hard',
                    onTap: () => setState(() => _mode = 'hard'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UISpacing.lg),
            Text('Intention', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            TextField(
              controller: _intentionController,
              decoration: InputDecoration(
                hintText: 'What do you want to focus on?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIRadius.md),
                ),
              ),
            ),
            const SizedBox(height: UISpacing.lg),
            Text('Duration: $_durationMinutes min',
              style: UITypography.heading3),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_durationMinutes min',
              onChanged: (v) => setState(() => _durationMinutes = v.round()),
            ),
            const SizedBox(height: UISpacing.lg),
            Text('Ambient Sound', style: UITypography.heading3),
            const SizedBox(height: UISpacing.sm),
            Wrap(
              spacing: 8,
              children: _soundOptions.map((opt) {
                return ChoiceChip(
                  label: Text(opt.$1),
                  selected: _ambientSound == opt.$2,
                  onSelected: (_) => setState(() => _ambientSound = opt.$2),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.primary,
                  foregroundColor: UIColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Begin Session',
                  style: UITypography.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label, desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label, required this.desc, required this.icon,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UISpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(UIRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
              color: selected ? cs.onPrimary : cs.primary),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w600,
              )),
            Text(desc,
              style: TextStyle(
                fontSize: 12,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              )),
          ],
        ),
      ),
    );
  }
}
