import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channels = {
    'session_complete': AndroidNotificationChannel(
      'session_complete', 'Session Complete',
      description: 'When a focus session ends',
      importance: Importance.high,
    ),
    'break_reminder': AndroidNotificationChannel(
      'break_eminder', 'Break Reminders',
      description: 'Break and stretch reminders',
      importance: Importance.defaultImportance,
    ),
    'daily_goal': AndroidNotificationChannel(
      'daily_goal', 'Daily Goal',
      description: 'Daily focus goal reminders',
      importance: Importance.defaultImportance,
    ),
    'scheduled': AndroidNotificationChannel(
      'scheduled', 'Scheduled Sessions',
      description: 'Reminders for scheduled focus times',
      importance: Importance.high,
    ),
    'challenge': AndroidNotificationChannel(
      'challenge', 'Challenges',
      description: 'Challenge progress and completions',
      importance: Importance.defaultImportance,
    ),
  };

  static Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidSettings));
    for (final channel in _channels.values) {
      await _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    }
    _initialized = true;
  }

  static Future<void> showSessionComplete({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _androidDetails('session_complete'));
  }

  static Future<void> showBreakReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _androidDetails('break_reminder'));
  }

  static Future<void> showDailyGoal({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _androidDetails('daily_goal'));
  }

  static Future<void> showScheduled({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _androidDetails('scheduled'));
  }

  static Future<void> showChallenge({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _androidDetails('challenge'));
  }

  static NotificationDetails _androidDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, _channels[channelId]?.name ?? channelId,
        channelDescription: _channels[channelId]?.description ?? '',
        styleInformation: const DefaultStyleInformation(true, true),
      ),
    );
  }
}
