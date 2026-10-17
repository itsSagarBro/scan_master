import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/qr_scanner_overlay.dart';
import 'package:scan_master/utils/text_styles.dart';

/// primary viewfinder screen that hosts the live camera feed,
/// top app bar controls, navigation drawer, and scan detection logic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // restart camera stream when resuming from background
    if (state == AppLifecycleState.resumed) {
      context.read<QrScannerBloc>().add(OnReturn(fromBackground: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// pauses the camera feed during navigation transitions
  /// and restarts the stream once the route pops back.
  Future<void> _loadScreen(String routeName) async {
    final scannerBloc = context.read<QrScannerBloc>();
    scannerBloc.add(PauseCamera());

    await context.push(routeName);

    if (!mounted) return;
    scannerBloc.add(StartCamera());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<QrScannerBloc, QrScannerState>(
      listener: (context, state) async {
        if (state.data != null) {
          final scannerBloc = context.read<QrScannerBloc>();
          await context.push('/scanned', extra: state.data);

          if (!mounted) return;
          scannerBloc.add(OnReturn());
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Scan Master',
              style: appBarHeading(),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              BlocBuilder<QrScannerBloc, QrScannerState>(
                builder: (context, scannerState) {
                  final isFlashOn = scannerState.flashOn ?? false;
                  return IconButton(
                    tooltip: isFlashOn ? 'Turn off flash' : 'Turn on flash',
                    onPressed: () =>
                        context.read<QrScannerBloc>().add(OnFlashClick()),
                    icon: Icon(
                      isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                    ),
                  );
                },
              ),
              const SizedBox(width: 5),
            ],
          ),
          drawer: SafeArea(
            child: Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      child: RichText(
                        text: TextSpan(
                          style: drawerTextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          children: [
                            const TextSpan(text: 'Scan Master'),
                            TextSpan(
                              text: '\nDeveloped by Sagar Patel',
                              style: defaultTextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.star_border_rounded,
                      size: 26,
                    ),
                    title: Text(
                      'Favorites',
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _loadScreen('/favorites');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.history_rounded,
                      size: 26,
                    ),
                    title: Text(
                      'History',
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _loadScreen('/history');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      size: 26,
                    ),
                    title: Text(
                      'Settings',
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _loadScreen('/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      size: 26,
                    ),
                    title: Text(
                      'About',
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _loadScreen('/about');
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (state.mobileScannerController != null)
                MobileScanner(
                  key: _qrKey,
                  onDetect: (barcodes) {
                    if (context.read<SettingsBloc>().saveHistory) {
                      context
                          .read<HistoryBloc>()
                          .add(OnAddHistoryClicked(barcodes));
                    }
                    context.read<QrScannerBloc>().add(OnScannedData(barcodes));
                  },
                  controller: state.mobileScannerController ??
                      MobileScannerController(),
                  overlayBuilder: (context, _) {
                    return Container(
                      decoration: ShapeDecoration(
                        shape: QrScannerOverlay(
                          borderColor: Colors.white,
                          borderRadius: 20,
                        ),
                      ),
                    );
                  },
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 100,
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _loadScreen('/history'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                            backgroundColor: theme.colorScheme.surface,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.history_rounded),
                              const SizedBox(width: 5),
                              Text(
                                'History',
                                style: centerFloatingHeading(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
