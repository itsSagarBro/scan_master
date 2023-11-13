import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/utils/qr_scanner_overlay.dart';
import 'package:scan_master/utils/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey qrKey = GlobalKey(debugLabel: "QR");

    return BlocConsumer<QrScannerBloc, QrScannerState>(
      listener: (context, state) async {
        if (state.data != null) {
          await context.push("/scanned", extra: state.data);
          // ignore: use_build_context_synchronously
          BlocProvider.of<QrScannerBloc>(context).add(OnReturnFromScanned());
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              "Scan Master",
              style: appBarHeading(),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu_rounded),
              iconSize: 26,
            ),
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
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.photo_rounded)),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (state.mobileScannerController != null)
                MobileScanner(
                  key: qrKey,
                  onDetect: (barcodes) {
                    BlocProvider.of<QrScannerBloc>(context)
                        .add(OnScannedData(barcodes));
                  },
                  controller: state.mobileScannerController!,
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onBackground,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background),
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code_2_rounded),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Create",
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
