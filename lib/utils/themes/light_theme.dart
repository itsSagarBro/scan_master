import 'package:flutter/material.dart';

/// application-wide light theme configuration based on material 3 guidelines.
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);
