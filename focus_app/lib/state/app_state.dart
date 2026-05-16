import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final userProvider = StateProvider<String?>((ref) => null);

final themeModeProvider = StateProvider<bool>((ref) => false);
