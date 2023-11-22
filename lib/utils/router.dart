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

GoRouter router = GoRouter(routes: [
  GoRoute(
      path: "/",
      pageBuilder: (context, state) => MaterialPage(
            child: BlocProvider(
              create: (context) => QrScannerBloc(),
              child: const HomeScreen(),
            ),
          ),
      routes: [
        GoRoute(
          path: "scanned",
          pageBuilder: (context, state) => CupertinoPage(
              child: BlocProvider(
            create: (context) => ScannedResultBloc(state.extra as ScannedModel),
            child: const ScannedScreen(),
          )),
        ),
        GoRoute(
          path: "settings",
          pageBuilder: (context, state) =>
              const MaterialPage(child: SettingsScreen()),
        ),
        GoRoute(
          path: "about",
          pageBuilder: (context, state) =>
              const MaterialPage(child: AboutScreen()),
        ),
        GoRoute(
            path: "history",
            pageBuilder: (context, state) =>
                const MaterialPage(child: HistoryScreen()),
            routes: [
              GoRoute(
                path: "scanned",
                pageBuilder: (context, state) => MaterialPage(
                    child: BlocProvider(
                  create: (context) =>
                      ScannedResultBloc(state.extra as ScannedModel),
                  child: const ScannedScreen(),
                )),
              )
            ]),
        GoRoute(
            path: "favorites",
            pageBuilder: (context, state) =>
                const MaterialPage(child: FavoritesScreen()),
            routes: [
              GoRoute(
                path: "scanned",
                pageBuilder: (context, state) => MaterialPage(
                    child: BlocProvider(
                  create: (context) =>
                      ScannedResultBloc(state.extra as ScannedModel),
                  child: const ScannedScreen(),
                )),
              )
            ])
      ])
]);
