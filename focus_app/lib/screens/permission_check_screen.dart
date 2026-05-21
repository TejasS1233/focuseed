import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/lock_service.dart';
import '../theme/theme.dart';

class PermissionCheckDialog {
  static Future<bool> canStartHardLock(BuildContext context) async {
    final initialOverlay = await LockService.hasOverlayPermission();
    final initialAccessibility = await LockService.isAccessibilityServiceEnabled();

    if (initialOverlay && initialAccessibility) return true;

    if (!context.mounted) return false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PermissionDialog(
        initialOverlay: initialOverlay,
        initialAccessibility: initialAccessibility,
      ),
    ).then((r) => r ?? false);
  }
}

class _PermissionDialog extends StatefulWidget {
  final bool initialOverlay;
  final bool initialAccessibility;

  const _PermissionDialog({
    required this.initialOverlay,
    required this.initialAccessibility,
  });

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  late bool _overlayOk;
  late bool _accessibilityOk;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _overlayOk = widget.initialOverlay;
    _accessibilityOk = widget.initialAccessibility;
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _check());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final overlay = await LockService.hasOverlayPermission();
    final accessibility = await LockService.isAccessibilityServiceEnabled();
    if (overlay != _overlayOk || accessibility != _accessibilityOk) {
      setState(() {
        _overlayOk = overlay;
        _accessibilityOk = accessibility;
      });
    }
  }

  bool get _allGranted => _overlayOk && _accessibilityOk;

  Future<void> _grantOverlay() async {
    await LockService.openOverlaySettings();
    await _check();
  }

  Future<void> _grantAccessibility() async {
    await LockService.openAccessibilitySettings();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _allGranted ? Icons.verified : Icons.shield_outlined,
              color: _allGranted ? AppColors.primary : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _allGranted ? 'All Set' : 'Permissions Required',
              style: AppTypography.heading2,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildPermissionItem(
            icon: Icons.picture_in_picture,
            title: 'Display Overlay',
            desc: 'Shows a blocking screen when you open a blacklisted app',
            granted: _overlayOk,
            onGrant: _grantOverlay,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.accessibility,
            title: 'Accessibility Service',
            desc: 'Detects when you open an app and redirects back',
            granted: _accessibilityOk,
            onGrant: _grantAccessibility,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _allGranted ? AppColors.primary.withOpacity(0.3) : context.border,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _allGranted ? Icons.check_circle : Icons.info_outline,
                  size: 16,
                  color: _allGranted ? AppColors.primary : context.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _allGranted
                        ? 'All permissions granted. Hard lock will work correctly.'
                        : 'Auto-checks every 2 seconds. Grant each permission and it updates here.',
                    style: AppTypography.bodySmall.copyWith(
                      color: _allGranted ? AppColors.primary : context.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!_allGranted)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
              style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
          ),
        SizedBox(
          child: ElevatedButton(
            onPressed: _allGranted ? () => Navigator.pop(context, true) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _allGranted ? AppColors.primary : context.surface,
              foregroundColor: _allGranted ? const Color(0xFF08080F) : context.textMuted,
              side: _allGranted ? null : BorderSide(color: context.border),
              disabledBackgroundColor: context.surface,
            ),
            child: Text(_allGranted ? 'Start Lock' : 'Waiting for permissions'),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool granted,
    required VoidCallback onGrant,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: granted ? AppColors.primary.withOpacity(0.3) : context.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: granted
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              granted ? Icons.check : icon,
              color: granted ? AppColors.primary : AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.heading3),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
              ],
            ),
          ),
          if (!granted)
            TextButton(
              onPressed: onGrant,
              child: Text('Grant', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('granted', style: AppTypography.caption.copyWith(
                color: AppColors.primary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
