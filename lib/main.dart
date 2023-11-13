import 'package:flutter/material.dart';
import 'package:scan_master/utils/themes/dark_theme.dart';
import 'package:scan_master/utils/themes/light_theme.dart';
import 'package:scan_master/utils/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scan Master',
      themeMode: ThemeMode.light,
      darkTheme: darkTheme,
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
