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
    } on MissingPluginException {
      // Android native code not available
    }
  }

  Future<void> stopLock() async {
    try {
      await _channel.invokeMethod('stopLock');
    } on MissingPluginException {
      // Android native code not available
    }
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _appChannel.invokeMethod('getInstalledApps');
      return List<Map<String, dynamic>>.from(result as List)
          .map((m) => Map<String, String>.from(m as Map))
          .toList();
    } on MissingPluginException {
      return [];
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      return await _appChannel.invokeMethod('hasOverlayPermission') as bool;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openOverlaySettings() async {
    try {
      await _appChannel.invokeMethod('openOverlaySettings');
    } on MissingPluginException {
      // ignore
    }
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return await _appChannel.invokeMethod('isAccessibilityServiceEnabled') as bool;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _appChannel.invokeMethod('openAccessibilitySettings');
    } on MissingPluginException {
      // ignore
    }
  }
}
