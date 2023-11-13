import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannedScreen extends StatelessWidget {
  const ScannedScreen({super.key, required this.data});

  final BarcodeCapture data;

  @override
  Widget build(BuildContext context) {
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
              width: double.maxFinite,
              child: Align(
                alignment: Alignment.center,
                child: data.image != null
                    ? Image.memory(
                        data.image!,
                        fit: BoxFit.contain,
                      )
                    : QrImageView(
                        data: data.barcodes[0].rawValue.toString(),
                        eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.onBackground),
                        dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            AutoSizeText(
              data.barcodes[0].displayValue.toString(),
              minFontSize: 14,
              maxLines: 3,
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
                  onPressed: () => launchUrl(
                      Uri.parse(data.barcodes[0].rawValue.toString())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  child: Text(
                    "Open in Browser",
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
                    onPressed: () {},
                    icon: const Icon(Icons.copy_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(fixedSize: const Size(60, 60)),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
