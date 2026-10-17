import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/bloc/scanned_result_bloc/scanned_result_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/screens/about_screen.dart';
import 'package:scan_master/screens/favorites_screen.dart';
import 'package:scan_master/screens/history_screen.dart';
import 'package:scan_master/screens/home_screen.dart';
import 'package:scan_master/screens/scanned_screen.dart';
import 'package:scan_master/screens/settings_screen.dart';

/// application route definitions using GoRouter
/// handles nested navigation, route transitions, and passing scan payloads
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        child: BlocProvider(
          create: (context) => QrScannerBloc(),
          child: const HomeScreen(),
        ),
      ),
      routes: [
        // detail route triggered directly from live scanner
        GoRoute(
          path: 'scanned',
          pageBuilder: (context, state) {
            final scanData = state.extra as ScannedModel;
            return CupertinoPage(
              child: BlocProvider(
                create: (context) => ScannedResultBloc(scanData),
                child: const ScannedScreen(),
              ),
            );
          },
        ),

        // settings screen
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => const MaterialPage(
            child: SettingsScreen(),
          ),
        ),

        // application and license information
        GoRoute(
          path: 'about',
          pageBuilder: (context, state) => const MaterialPage(
            child: AboutScreen(),
          ),
        ),

        // scan history log and its detail route
        GoRoute(
          path: 'history',
          pageBuilder: (context, state) => const MaterialPage(
            child: HistoryScreen(),
          ),
          routes: [
            GoRoute(
              path: 'scanned',
              pageBuilder: (context, state) {
                final scanData = state.extra as ScannedModel;
                return MaterialPage(
                  child: BlocProvider(
                    create: (context) => ScannedResultBloc(scanData),
                    child: const ScannedScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        // starred or bookmarked scans and its detail route
        GoRoute(
          path: 'favorites',
          pageBuilder: (context, state) => const MaterialPage(
            child: FavoritesScreen(),
          ),
          routes: [
            GoRoute(
              path: 'scanned',
              pageBuilder: (context, state) {
                final scanData = state.extra as ScannedModel;
                return MaterialPage(
                  child: BlocProvider(
                    create: (context) => ScannedResultBloc(scanData),
                    child: const ScannedScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
