import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/themes/dark_theme.dart';
import 'package:scan_master/utils/themes/light_theme.dart';
import 'package:scan_master/utils/router.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("history");
  await Hive.openBox("settings");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HistoryBloc(),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Scan Master',
            themeMode: state.themeMode,
            darkTheme: darkTheme,
            theme: lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
