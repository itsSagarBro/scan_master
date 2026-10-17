import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

/// displays detailed information for a scanned code, renders its visual barcode preview,
/// and provides utility actions such as copy, download, share, and auto-actions.
class ScannedScreen extends StatefulWidget {
  const ScannedScreen({super.key});

  @override
  State<ScannedScreen> createState() => _ScannedScreenState();
}

class _ScannedScreenState extends State<ScannedScreen> {
  bool _hasExecutedAutoActions = false;

  @override
  void initState() {
    super.initState();

    // execute automated settings actions once after the first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeInitialAutoActions();
    });
  }

  /// evaluates user preferences such as auto-copy, auto-open url, and auto-download
  /// only when the record is freshly scanned rather than revisited from history
  void _executeInitialAutoActions() {
    if (!mounted || _hasExecutedAutoActions) return;

    final scannedBloc = context.read<ScannedResultBloc>();
    final settingsBloc = context.read<SettingsBloc>();
    final historyBloc = context.read<HistoryBloc>();
    final scannedModel = scannedBloc.state.scannedModel;

    final rawList = scannedModel.raw as List;
    final barcode = Barcode.fromNative(rawList.first as Map);
    final displayText = getDisplayValue(barcode);

    // check if item already existed in history; if null, it is an active new scan
    final isNewScan = scannedModel.id == null ||
        historyBloc.state.getOneData(scannedModel.id!) == null;

    if (isNewScan) {
      if (settingsBloc.autoCopy) {
        scannedBloc.add(OnCopyClick(displayText));
      } else if (settingsBloc.autoOpenUrl && barcode.type == BarcodeType.url) {
        scannedBloc.add(OnActionClick(barcode));
      }

      if (settingsBloc.qrAutoDownload) {
        scannedBloc.add(DownloadQrCodeImage());
      }
    }

    _hasExecutedAutoActions = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ScannedResultBloc, ScannedResultState>(
      builder: (context, state) {
        final rawList = state.scannedModel.raw as List;
        final barcode = Barcode.fromNative(rawList.first as Map);
        final displayText = getDisplayValue(barcode);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Scanned Result',
              style: appBarHeading(),
            ),
            actions: [
              BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, historyState) {
                  final data = historyState.getRecentData();
                  final recentModel =
                      data != null ? ScannedModel.fromJson(data) : null;
                  final isFavorite = recentModel?.favorite ?? false;
                  final recordId = recentModel?.id;

                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'favorite' && recordId != null) {
                        context
                            .read<HistoryBloc>()
                            .add(OnFavoriteToggleClicked(recordId));
                      } else if (value == 'settings') {
                        context.push('/settings');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'favorite',
                        child: Text(
                          isFavorite
                              ? 'Mark as Unfavorite'
                              : 'Mark as Favorite',
                          style: defaultTextStyle(fontSize: 14),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'settings',
                        child: Text(
                          'Settings',
                          style: defaultTextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    position: PopupMenuPosition.under,
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // visual barcode reproduction
                  SizedBox(
                    height: 220,
                    width: barcode.format == BarcodeFormat.qrCode
                        ? 220
                        : double.maxFinite,
                    child: Center(
                      child: state.screenshotController != null
                          ? Screenshot(
                              controller: state.screenshotController!,
                              child: barcode_widget.BarcodeWidget(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(10),
                                data: barcode.rawValue ?? '',
                                barcode: getQrType(barcode.format),
                                drawText: false,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (theme.colorScheme.brightness == Brightness.dark)
                    const SizedBox(height: 10),
                  AutoSizeText(
                    displayText,
                    minFontSize: 14,
                    maxLines: 5,
                    wrapWords: false,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: defaultTextStyle(),
                  ),
                  const SizedBox(height: 20),
                  // primary dynamic action button
                  SizedBox(
                    width: 250,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () => context
                          .read<ScannedResultBloc>()
                          .add(OnActionClick(barcode)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                      ),
                      child: Text(
                        getButtonText(barcode),
                        style: qrOpenButtonTextStyle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(endIndent: 10),
                        ),
                        Text(
                          'or',
                          style: defaultTextStyle(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const Expanded(
                          child: Divider(indent: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // utility action buttons
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => context
                              .read<ScannedResultBloc>()
                              .add(OnCopyClick(displayText)),
                          icon: const Icon(Icons.copy_rounded),
                          iconSize: 28,
                          tooltip: 'Copy Text',
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(60, 60),
                          ),
                        ),
                        const SizedBox(width: 15),
                        IconButton.filledTonal(
                          onPressed: () =>
                              context.read<ScannedResultBloc>().add(
                                    OnDownloadClick(
                                      barcode.displayValue ?? 'Unknown',
                                    ),
                                  ),
                          icon: const Icon(Icons.download_rounded),
                          iconSize: 28,
                          tooltip: 'Download QR',
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(60, 60),
                          ),
                        ),
                        const SizedBox(width: 15),
                        IconButton.filledTonal(
                          onPressed: () =>
                              context.read<ScannedResultBloc>().add(
                                    OnShareClick(
                                      value: displayText,
                                      shareImage: context
                                          .read<SettingsBloc>()
                                          .shareQrImage,
                                    ),
                                  ),
                          icon: const Icon(Icons.share_rounded),
                          iconSize: 28,
                          tooltip: 'Share Text',
                          enableFeedback: true,
                          style: IconButton.styleFrom(
                            fixedSize: const Size(60, 60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
