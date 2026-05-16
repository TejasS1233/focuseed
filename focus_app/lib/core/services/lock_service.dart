import 'package:flutter/services.dart';

class LockService {
  static const _channel = MethodChannel('com.focusapp/lock');

  Future<void> startLock({required int durationMinutes}) async {
    await _channel.invokeMethod('startLock', {
      'durationMinutes': durationMinutes,
    });
  }

  Future<void> stopLock() async {
    await _channel.invokeMethod('stopLock');
  }

  Future<bool> isLocked() async {
    final result = await _channel.invokeMethod<bool>('isLocked');
    return result ?? false;
  }
}
