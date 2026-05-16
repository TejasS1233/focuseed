import 'dart:io';

class PermissionService {
  Future<bool> requestNotificationPermission() async {
    return true;
  }

  Future<bool> requestOverlayPermission() async {
    if (Platform.isAndroid) {
    }
    return true;
  }

  Future<bool> requestAccessibilityPermission() async {
    return true;
  }

  bool hasHardlockSupport() => Platform.isAndroid;
}
