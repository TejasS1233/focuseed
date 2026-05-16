import 'package:flutter/services.dart';

class LockService {
  static const _channel = MethodChannel('focus_garden/lock');

  Future<void> startLock({required int durationMinutes}) async {
    try {
      await _channel.invokeMethod('startLock', {
        'durationMinutes': durationMinutes,
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
}
