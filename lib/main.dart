import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/router.dart';
import 'package:scan_master/utils/themes/dark_theme.dart';
import 'package:scan_master/utils/themes/light_theme.dart';

void main() async {
  // ensure flutter engine bindings are ready before running asynchronous services
  WidgetsFlutterBinding.ensureInitialized();

  // initialize local storage engine
  await Hive.initFlutter();

  // open boxes for scan records and user configuration
  await Hive.openBox('history');
  await Hive.openBox('settings');

  runApp(const MyApp());
}

/// root application widget configuring global state providers, routing, and dynamic theme switching
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
