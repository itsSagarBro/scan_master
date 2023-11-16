import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcodeWidget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/scanned_result_bloc/scanned_result_bloc.dart';
import 'package:scan_master/utils/get_button_text.dart';
import 'package:scan_master/utils/get_scanned_values.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:screenshot/screenshot.dart';

class ScannedScreen extends StatelessWidget {
  const ScannedScreen({super.key, required this.data});

  final BarcodeCapture data;

  barcodeWidget.Barcode getQrType(BarcodeFormat format) {
    barcodeWidget.Barcode barcode = barcodeWidget.Barcode.qrCode();

    switch (format) {
      case BarcodeFormat.aztec:
        barcode = barcodeWidget.Barcode.aztec();
        break;
      case BarcodeFormat.codabar:
        barcode = barcodeWidget.Barcode.codabar();
        break;
      case BarcodeFormat.code128:
        barcode = barcodeWidget.Barcode.code128();
        break;
      case BarcodeFormat.code39:
        barcode = barcodeWidget.Barcode.code39();
        break;
      case BarcodeFormat.code93:
        barcode = barcodeWidget.Barcode.code93();
        break;
      case BarcodeFormat.dataMatrix:
        barcode = barcodeWidget.Barcode.dataMatrix();
        break;
      case BarcodeFormat.ean13:
        barcode = barcodeWidget.Barcode.ean13();
        break;
      case BarcodeFormat.ean8:
        barcode = barcodeWidget.Barcode.ean8();
        break;
      case BarcodeFormat.itf:
        barcode = barcodeWidget.Barcode.itf();
        break;
      case BarcodeFormat.pdf417:
        barcode = barcodeWidget.Barcode.pdf417();
        break;
      case BarcodeFormat.upcA:
        barcode = barcodeWidget.Barcode.upcA();
        break;
      case BarcodeFormat.upcE:
        barcode = barcodeWidget.Barcode.upcE();
        break;
      default:
        barcode = barcodeWidget.Barcode.qrCode();
        break;
    }

    return barcode;
  }

  @override
  Widget build(BuildContext context) {
    Barcode barcode = data.barcodes[0];
    String displayText = getDisplayValue(barcode);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Scanned Result",
        style: appBarHeading(),
      )),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              width: barcode.format == BarcodeFormat.qrCode
                  ? 220
                  : double.maxFinite,
              child: BlocBuilder<ScannedResultBloc, ScannedResultState>(
                builder: (context, state) {
                  return Center(
                    child: Screenshot(
                      controller: state.screenshotController!,
                      child: barcodeWidget.BarcodeWidget(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                        data: barcode.rawValue.toString(),
                        barcode: getQrType(barcode.format),
                        drawText: false,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (Theme.of(context).colorScheme.brightness == Brightness.dark)
              const SizedBox(
                height: 10,
              ),
            AutoSizeText(
              displayText,
              minFontSize: 14,
              maxLines: 5,
              wrapWords: false,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: defaultTextStyle(),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              height: 70,
              child: ElevatedButton(
                  onPressed: () => BlocProvider.of<ScannedResultBloc>(context)
                      .add(OnActionClick(barcode)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  child: Text(
                    getButtonText(barcode),
                    style: qrOpenButtonTextStyle(),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: Row(
                children: [
                  const Expanded(
                      child: Divider(
                    endIndent: 10,
                  )),
                  Text(
                    "or",
                    style: defaultTextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  const Expanded(
                      child: Divider(
                    indent: 10,
                  ))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 80,
              width: double.maxFinite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => BlocProvider.of<ScannedResultBloc>(context)
                        .add(OnCopyClick(displayText)),
                    icon: const Icon(Icons.copy_rounded),
                    iconSize: 28,
                    tooltip: "Copy Text",
                    enableFeedback: true,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  IconButton.filledTonal(
                    onPressed: () => BlocProvider.of<ScannedResultBloc>(context)
                        .add(
                            OnDownloadClick(barcode.displayValue ?? "Unknown")),
                    icon: const Icon(Icons.download_rounded),
                    iconSize: 28,
                    tooltip: "Download QR",
                    enableFeedback: true,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  IconButton.filledTonal(
                    onPressed: () => BlocProvider.of<ScannedResultBloc>(context)
                        .add(OnShareClick(displayText)),
                    icon: const Icon(Icons.share_rounded),
                    iconSize: 28,
                    tooltip: "Share Text",
                    enableFeedback: true,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
