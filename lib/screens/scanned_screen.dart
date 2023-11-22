import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/scanned_result_bloc/scanned_result_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/utils/get_button_text.dart';
import 'package:scan_master/utils/get_qr_type.dart';
import 'package:scan_master/utils/get_scanned_values.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:screenshot/screenshot.dart';

class ScannedScreen extends StatelessWidget {
  const ScannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannedResultBloc, ScannedResultState>(
      builder: (context, state) {
        // This convers raw data into barcode for future use
        Barcode barcode = (state.scannedModel.raw as List)
            .map((e) => Barcode.fromNative(e))
            .toList()
            .first;

        // This converts raw data into readable format
        String displayText = getDisplayValue(barcode);

        // This function will take action for all auto options and resctrict
        //this options from calling when coming from other state
        if (BlocProvider.of<HistoryBloc>(context)
                .state
                .getOneData(state.scannedModel.id!) ==
            null) {
          if (BlocProvider.of<SettingsBloc>(context).autoCopy) {
            BlocProvider.of<ScannedResultBloc>(context)
                .add(OnCopyClick(displayText));
          } else if (BlocProvider.of<SettingsBloc>(context).autoOpenUrl &&
              barcode.type == BarcodeType.url) {
            BlocProvider.of<ScannedResultBloc>(context)
                .add(OnActionClick(barcode));
          }

          if (BlocProvider.of<SettingsBloc>(context).qrAutoDownload) {
            BlocProvider.of<ScannedResultBloc>(context)
                .add(DownloadQrCodeImage());
          }
        }

        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Scanned Result",
                style: appBarHeading(),
              ),
              actions: [
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, historyState) {
                    var data = historyState.getRecentData();
                    ScannedModel scannedModel = ScannedModel.fromJson(data);
                    return PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            onTap: () => BlocProvider.of<HistoryBloc>(context)
                                .add(OnFavoriteToggleClicked(scannedModel.id!)),
                            child: Text(
                              scannedModel.favorite!
                                  ? "Mark as Unfavorite"
                                  : "Mark as Favorite",
                              style: defaultTextStyle(fontSize: 14),
                            )),
                        PopupMenuItem(
                            child: Text(
                          "Settings",
                          style: defaultTextStyle(fontSize: 14),
                        ))
                      ],
                      position: PopupMenuPosition.under,
                      enableFeedback: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    );
                  },
                )
              ],
            ),
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
                    child: Center(
                      child: Screenshot(
                        controller: state.screenshotController!,
                        child: barcode_widget.BarcodeWidget(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                          data: barcode.rawValue.toString(),
                          barcode: getQrType(barcode.format),
                          drawText: false,
                        ),
                      ),
                    ),
                  ),
                  if (Theme.of(context).colorScheme.brightness ==
                      Brightness.dark)
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
                        onPressed: () =>
                            BlocProvider.of<ScannedResultBloc>(context)
                                .add(OnActionClick(barcode)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
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
                          onPressed: () =>
                              BlocProvider.of<ScannedResultBloc>(context)
                                  .add(OnCopyClick(displayText)),
                          icon: const Icon(Icons.copy_rounded),
                          iconSize: 28,
                          tooltip: "Copy Text",
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                              fixedSize: const Size(60, 60)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        IconButton.filledTonal(
                          onPressed: () =>
                              BlocProvider.of<ScannedResultBloc>(context).add(
                                  OnDownloadClick(
                                      barcode.displayValue ?? "Unknown")),
                          icon: const Icon(Icons.download_rounded),
                          iconSize: 28,
                          tooltip: "Download QR",
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                              fixedSize: const Size(60, 60)),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        IconButton.filledTonal(
                          onPressed: () =>
                              BlocProvider.of<ScannedResultBloc>(context).add(
                                  OnShareClick(
                                      value: displayText,
                                      shareImage:
                                          BlocProvider.of<SettingsBloc>(context)
                                              .shareQrImage)),
                          icon: const Icon(Icons.share_rounded),
                          iconSize: 28,
                          tooltip: "Share Text",
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                              fixedSize: const Size(60, 60)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )));
      },
    );
  }
}
