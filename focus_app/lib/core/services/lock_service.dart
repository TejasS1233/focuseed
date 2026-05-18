import 'package:flutter/services.dart';

class LockService {
  static const _channel = MethodChannel('focus_garden/lock');
  static const _appChannel = MethodChannel('focus_garden/apps');

  Future<void> startLock({
    required int durationMinutes,
    bool hardLock = false,
    List<String> blacklist = const [],
  }) async {
    try {
      await _channel.invokeMethod('startLock', {
        'durationMinutes': durationMinutes,
        'hardLock': hardLock,
        'blacklist': blacklist,
      });
    } catch (_) {}
  }

  Future<void> stopLock() async {
    try {
      await _channel.invokeMethod('stopLock');
    } catch (_) {}
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _appChannel.invokeMethod('getInstalledApps')
          .timeout(const Duration(seconds: 5));
      return (result as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      return await _appChannel.invokeMethod('hasOverlayPermission') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _appChannel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return await _appChannel.invokeMethod('isAccessibilityServiceEnabled') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _appChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }
}
