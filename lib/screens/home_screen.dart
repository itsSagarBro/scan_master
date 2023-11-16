import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/utils/qr_scanner_overlay.dart';
import 'package:scan_master/utils/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  GlobalKey qrKey = GlobalKey(debugLabel: "QR");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        BlocProvider.of<QrScannerBloc>(context).add(OnReturn());
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> loadScreen(String name) async {
    BlocProvider.of<QrScannerBloc>(context).add(PauseCamera());
    await context.push(name);
    // ignore: use_build_context_synchronously
    BlocProvider.of<QrScannerBloc>(context).add(StartCamera());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrScannerBloc, QrScannerState>(
      listener: (context, state) async {
        if (state.data != null) {
          await context.push("/scanned", extra: state.data);
          // ignore: use_build_context_synchronously
          BlocProvider.of<QrScannerBloc>(context).add(OnReturn());
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Scan Master",
              style: appBarHeading(),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              BlocBuilder<QrScannerBloc, QrScannerState>(
                builder: (context, state) {
                  return IconButton(
                      onPressed: () => BlocProvider.of<QrScannerBloc>(context)
                          .add(OnFlashClick()),
                      icon: Icon(state.flashOn ?? false
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded));
                },
              ),
              const SizedBox(
                width: 5,
              )
            ],
          ),
          drawer: SafeArea(
            child: Drawer(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Column(
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(.5)),
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        child: RichText(
                          text: TextSpan(
                              style: drawerTextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                              children: [
                                const TextSpan(text: "Scan Master"),
                                TextSpan(
                                    text: "\nDeveloped by Sagar Patel",
                                    style: defaultTextStyle(fontSize: 12))
                              ]),
                        ),
                      )),
                  // ListTile(
                  //   leading: const Icon(
                  //     Icons.qr_code_rounded,
                  //     size: 26,
                  //   ),
                  //   title: Text(
                  //     "Create",
                  //     style: defaultTextStyle(),
                  //   ),
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(15)),
                  //   dense: true,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     context.go("/create");
                  //   },
                  // ),
                  ListTile(
                    leading: const Icon(
                      Icons.star_border_rounded,
                      size: 26,
                    ),
                    title: Text(
                      "Favorites",
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    dense: true,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.history_rounded,
                      size: 26,
                    ),
                    title: Text(
                      "History",
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      loadScreen("/history");
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      size: 26,
                    ),
                    title: Text(
                      "Settings",
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    dense: true,
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      size: 26,
                    ),
                    title: Text(
                      "About",
                      style: defaultTextStyle(),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    dense: true,
                    onTap: () {},
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
                  key: qrKey,
                  autoLifecycle: false,
                  onDetect: (barcodes) {
                    BlocProvider.of<QrScannerBloc>(context)
                        .add(OnScannedData(barcodes));
                  },
                  controller: state.mobileScannerController ??
                      MobileScannerController(),
                  overlay: Container(
                    decoration: ShapeDecoration(
                        shape: QrScannerOverlay(
                            borderColor: Colors.white, borderRadius: 20)),
                  ),
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
                            onPressed: () {
                              loadScreen("/history");
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background),
                            child: Row(
                              children: [
                                const Icon(Icons.history_rounded),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "History",
                                  style: centerFloatingHeading(),
                                ),
                              ],
                            )),
                      )
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
