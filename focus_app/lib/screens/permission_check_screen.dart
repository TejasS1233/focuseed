import 'package:flutter/material.dart';
import '../core/services/lock_service.dart';
import '../theme/theme.dart';

class PermissionCheckDialog {
  static Future<bool> canStartHardLock(BuildContext context) async {
    final overlayOk = await LockService.hasOverlayPermission();
    final accessibilityOk = await LockService.isAccessibilityServiceEnabled();

    if (overlayOk && accessibilityOk) return true;

    if (!context.mounted) return false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Hard Lock Requires Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!overlayOk) ...[
              _PermissionItem(
                icon: Icons.picture_in_picture,
                title: 'Display Overlay',
                desc: 'Required to block blacklisted apps',
                onGrant: () => LockService.openOverlaySettings(),
              ),
              const SizedBox(height: 12),
            ],
            if (!accessibilityOk) ...[
              _PermissionItem(
                icon: Icons.accessibility,
                title: 'Accessibility Service',
                desc: 'Required to detect when you open an app',
                onGrant: () => LockService.openAccessibilitySettings(),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'Without these permissions, hard lock will fall back to grayscale mode.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start Anyway'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ) ?? false;
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final VoidCallback onGrant;

  const _PermissionItem({
    required this.icon, required this.title, required this.desc,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: UIColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        TextButton(
          onPressed: onGrant,
          child: const Text('Grant', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
