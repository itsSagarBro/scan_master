import 'package:flutter/material.dart';

/// application-wide dark theme configuration based on material 3 guidelines.
final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
