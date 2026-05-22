import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/db/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final userProvider = StateProvider<String?>((ref) => null);

final themeModeProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);

final initialDarkProvider = Provider<bool>((ref) => true);

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(initialDarkProvider);

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', newValue);
  }

  Future<void> setDark(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', value);
  }
}
