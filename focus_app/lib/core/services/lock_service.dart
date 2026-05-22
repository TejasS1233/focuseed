import 'package:flutter/foundation.dart';
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
    } catch (e) {
      debugPrint('LockService.startLock failed: $e');
    }
  }

  Future<void> stopLock() async {
    try {
      await _channel.invokeMethod('stopLock');
    } catch (e) {
      debugPrint('LockService.stopLock failed: $e');
    }
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _appChannel.invokeMethod('getInstalledApps')
          .timeout(const Duration(seconds: 5));
      return (result as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (e) {
      debugPrint('LockService.getInstalledApps failed: $e');
      return [];
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      return await _appChannel.invokeMethod('hasOverlayPermission') as bool;
    } catch (e) {
      debugPrint('LockService.hasOverlayPermission failed: $e');
      return false;
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _appChannel.invokeMethod('openOverlaySettings');
    } catch (e) {
      debugPrint('LockService.openOverlaySettings failed: $e');
    }
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return await _appChannel.invokeMethod('isAccessibilityServiceEnabled') as bool;
    } catch (e) {
      debugPrint('LockService.isAccessibilityServiceEnabled failed: $e');
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _appChannel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      debugPrint('LockService.openAccessibilitySettings failed: $e');
    }
  }
}
