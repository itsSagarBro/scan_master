import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/bloc/scanned_result_bloc/scanned_result_bloc.dart';
import 'package:scan_master/screens/home_screen.dart';
import 'package:scan_master/screens/scanned_screen.dart';

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
            create: (context) => ScannedResultBloc(),
            child: ScannedScreen(data: state.extra as BarcodeCapture),
          )),
        )
      ])
]);
