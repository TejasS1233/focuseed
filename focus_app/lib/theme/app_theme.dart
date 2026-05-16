import 'package:flutter/material.dart';

class AppTheme {
  static const _greenSeed = Color(0xFF2E7D32);

  static ThemeData get light => ThemeData(
    colorSchemeSeed: _greenSeed,
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static ThemeData get dark => ThemeData(
    colorSchemeSeed: _greenSeed,
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}
