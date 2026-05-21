import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _androidName = 'FocusWidgetProvider';

  static Future<void> updateWidget({
    required int streak,
    required int todayMinutes,
  }) async {
    await HomeWidget.saveWidgetData('streak', streak);
    await HomeWidget.saveWidgetData('today_minutes', todayMinutes);
    await HomeWidget.updateWidget(androidName: _androidName);
  }
}
