import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:scan_master/utils/themes/dark_theme.dart';
import 'package:scan_master/utils/themes/light_theme.dart';
import 'package:scan_master/utils/router.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("history");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scan Master',
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      theme: lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
