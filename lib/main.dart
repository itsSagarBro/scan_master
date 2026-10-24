import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/router.dart';
import 'package:scan_master/utils/themes/dark_theme.dart';
import 'package:scan_master/utils/themes/light_theme.dart';

const MethodChannel _tileChannel =
    MethodChannel('dev.sagarpatel.scanmaster/tile');
const MethodChannel _shortcutChannel =
    MethodChannel('dev.sagarpatel.scanmaster/shortcuts');

void _handleShortcutRoute(String? action) {
  if (action == null) return;

  switch (action) {
    case 'scan_camera':
      router.go('/');
      break;
    case 'scan_gallery':
      router.go('/?action=gallery');
      break;
    case 'create_qr':
      router.go('/create');
      break;
  }
}

void _initNativeListeners() {
  // 1. Quick Settings Tile: warm background click
  _tileChannel.setMethodCallHandler((call) async {
    if (call.method == 'onTileClicked') {
      router.go('/');
    }
  });

  // 2. Quick Settings Tile: cold launch
  _tileChannel.invokeMethod<bool>('checkTileLaunch').then((wasTileLaunch) {
    if (wasTileLaunch == true) {
      router.go('/');
    }
  }).catchError((_) {});

  // 3. Launcher Shortcuts: warm background click
  _shortcutChannel.setMethodCallHandler((call) async {
    if (call.method == 'onShortcutTriggered') {
      final action = call.arguments as String?;
      _handleShortcutRoute(action);
    }
  });

  // 4. Launcher Shortcuts: cold launch
  _shortcutChannel.invokeMethod<String>('getInitialShortcut').then((action) {
    _handleShortcutRoute(action);
  }).catchError((_) {});
}

void main() {
  runZonedGuarded<Future<void>>(() async {
    // 1. Ensure Flutter engine bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Lock application strictly to portrait mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 3. Configure edge-to-edge transparent system overlay chrome
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 4. Attach quick settings tile & launcher shortcuts listener
    _initNativeListeners();

    // 5. Catch framework rendering and build pipeline errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    // 6. Catch platform-level asynchronous errors
    PlatformDispatcher.instance.onError = (error, stack) {
      return true; // Prevents crash propagation
    };

    // 7. Initialize and open Hive local storage boxes
    await Hive.initFlutter();
    await Hive.openBox('history');
    await Hive.openBox('settings');

    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Uncaught app-level exception: $error\n$stack');
  });
}

/// Root application widget configuring global state providers, routing, and dynamic theme switching
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
          final isDark = state.themeMode == ThemeMode.dark ||
              (state.themeMode == ThemeMode.system &&
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
            child: MaterialApp.router(
              title: 'Scan Master',
              themeMode: state.themeMode,
              darkTheme: darkTheme,
              theme: lightTheme,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
