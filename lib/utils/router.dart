import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/screens/home_screen.dart';
import 'package:scan_master/screens/scanned_screen.dart';

GoRouter router = GoRouter(routes: [
  GoRoute(
      path: "/",
      pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              create: (context) => QrScannerBloc(),
              child: const HomeScreen(),
            ),
          ),
      routes: [
        GoRoute(
          path: "scanned",
          pageBuilder: (context, state) => CupertinoPage(
              child: ScannedScreen(data: state.extra as BarcodeCapture)),
        )
      ])
]);
