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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Permissions Required', style: AppTypography.heading2)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Without these permissions, hard lock will fall back to grayscale mode.',
                      style: AppTypography.bodySmall.copyWith(color: context.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Start Anyway',
              style: AppTypography.bodySmall.copyWith(color: context.textMuted)),
          ),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surface,
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.border),
              ),
              child: const Text('Cancel'),
            ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.error, size: 18),
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
          TextButton(
            onPressed: onGrant,
            child: Text('Grant', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
