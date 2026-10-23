import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/bloc/scanned_result_bloc/scanned_result_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/screens/about_screen.dart';
import 'package:scan_master/screens/create_screen.dart';
import 'package:scan_master/screens/favorites_screen.dart';
import 'package:scan_master/screens/history_screen.dart';
import 'package:scan_master/screens/home_screen.dart';
import 'package:scan_master/screens/scanned_screen.dart';
import 'package:scan_master/screens/settings_screen.dart';

/// Central navigation hub for Scan Master using declarative GoRouter.
///
/// Route Structure:
/// - Root (`/`): Camera viewfinder & main control deck (scoped QrScannerBloc).
///   ├── `/scanned`: Hero result view directly following live camera scan.
///   ├── `/create`: QR & Barcode generation suite.
///   ├── `/history`: Paginated chronological scan log.
///   │    └── `scanned`: Reusable detail viewer for selected historical scans.
///   ├── `/favorites`: Filtered bookmarked scans.
///   │    └── `scanned`: Reusable detail viewer for bookmarked items.
///   ├── `/settings`: User preferences (theme, retention policy, automations).
///   └── `/about`: App metadata, package version info, and developer profile.
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Primary Entry Point: Camera Scanner
    // We bind QrScannerBloc at this route level so camera controllers and flash state
    // cleanly release and re-initialize when navigating back and forth.
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        child: BlocProvider(
          create: (context) => QrScannerBloc(),
          child: const HomeScreen(),
        ),
      ),
      routes: [
        // Live Scan Result
        // Uses CupertinoPage transition for a smooth iOS-style push animation
        // right as camera analysis completes.
        GoRoute(
          path: 'scanned',
          pageBuilder: (context, state) {
            final scanData = state.extra is ScannedModel
                ? state.extra as ScannedModel
                : ScannedModel(rawValue: state.extra?.toString());

            return CupertinoPage(
              child: BlocProvider(
                create: (context) => ScannedResultBloc(scanData),
                child: const ScannedScreen(),
              ),
            );
          },
        ),

        // QR & Barcode Generator Screen
        // Allows generating custom QR payloads (URLs, Wi-Fi, text, contacts).
        GoRoute(
          path: 'create',
          pageBuilder: (context, state) => const MaterialPage(
            child: CreateScreen(),
          ),
        ),

        // Settings Screen
        // Handles theme switcher, auto-copy toggles, and storage auto-pruning.
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => const MaterialPage(
            child: SettingsScreen(),
          ),
        ),

        // Application Metadata & Credits
        // Displays dynamic package info, repository links, and licensing details.
        GoRoute(
          path: 'about',
          pageBuilder: (context, state) => const MaterialPage(
            child: AboutScreen(),
          ),
        ),

        // Scan History Log
        // Lists all persisted scan entries chronologically.
        GoRoute(
          path: 'history',
          pageBuilder: (context, state) => const MaterialPage(
            child: HistoryScreen(),
          ),
          routes: [
            // Inspect an existing history record
            // Nested under /history/scanned to maintain natural back-stack hierarchy.
            GoRoute(
              path: 'scanned',
              pageBuilder: (context, state) {
                final scanData = state.extra is ScannedModel
                    ? state.extra as ScannedModel
                    : ScannedModel(rawValue: state.extra?.toString());

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

        // Starred / Favorites Feed
        // Quick access to frequently used or pinned scans.
        GoRoute(
          path: 'favorites',
          pageBuilder: (context, state) => const MaterialPage(
            child: FavoritesScreen(),
          ),
          routes: [
            // Inspect an existing bookmarked record
            // Nested under /favorites/scanned to keep navigation contexts isolated.
            GoRoute(
              path: 'scanned',
              pageBuilder: (context, state) {
                final scanData = state.extra is ScannedModel
                    ? state.extra as ScannedModel
                    : ScannedModel(rawValue: state.extra?.toString());

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
