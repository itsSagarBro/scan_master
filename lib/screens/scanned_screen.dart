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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeInitialAutoActions();
    });
  }

  /// Extracts the effective string payload from any available field
  String _resolveRawPayload(ScannedModel model) {
    if (model.rawValue != null && model.rawValue!.trim().isNotEmpty) {
      return model.rawValue!.trim();
    }
    if (model.name != null &&
        model.name!.trim().isNotEmpty &&
        model.name != 'Barcode' &&
        model.name != 'Unknown') {
      return model.name!.trim();
    }

    final rawData = model.raw;
    if (rawData is List && rawData.isNotEmpty) {
      final first = rawData.first;
      if (first is Map) {
        final val = first['rawValue'] ??
            first['displayValue'] ??
            first['formattedValue'] ??
            first['value'];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString().trim();
        }
      }
    }
    return '';
  }

  /// Resolves the Barcode instance prioritizing typed fields, fallback string, or legacy maps
  Barcode? _extractBarcode(ScannedModel model) {
    final payload = _resolveRawPayload(model);
    if (payload.isNotEmpty) {
      return Barcode(
        rawValue: payload,
        displayValue: model.name ?? payload,
        format: model.format ?? BarcodeFormat.qrCode,
        type: model.type ?? BarcodeType.text,
      );
    }

    final rawData = model.raw;
    if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      try {
        return Barcode.fromNative(
            Map<Object?, Object?>.from(rawData.first as Map));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _executeInitialAutoActions() {
    if (!mounted || _hasExecutedAutoActions) return;

    final scannedBloc = context.read<ScannedResultBloc>();
    final settingsBloc = context.read<SettingsBloc>();
    final historyBloc = context.read<HistoryBloc>();
    final scannedModel = scannedBloc.state.scannedModel;

    final barcode = _extractBarcode(scannedModel);
    if (barcode == null) return;

    final displayText = getDisplayValue(barcode);

    final isNewScan = scannedModel.id == null ||
        historyBloc.state.getOneData(scannedModel.id!) == null;

    if (isNewScan) {
      if (settingsBloc.autoCopy) {
        scannedBloc.add(OnCopyClick(displayText));
      } else if (settingsBloc.autoOpenUrl && barcode.type == BarcodeType.url) {
        scannedBloc.add(OnActionClick(barcode));
      }

      if (settingsBloc.qrAutoDownload) {
        scannedBloc.add(const DownloadQrCodeImage());
      }
    }

    _hasExecutedAutoActions = true;
  }

  Widget _buildBarcodePreview({
    required ScreenshotController screenshotController,
    required String rawData,
    required BarcodeFormat format,
  }) {
    final cleanData = rawData.trim();
    if (cleanData.isEmpty) {
      return const SizedBox(
        height: 180,
        width: 180,
        child: Center(
          child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
        ),
      );
    }

    final isQr = format == BarcodeFormat.qrCode;
    final targetBarcode = getQrType(format);

    bool canEncode = false;
    try {
      targetBarcode.verify(cleanData);
      canEncode = true;
    } catch (_) {
      canEncode = false;
    }

    final finalBarcode =
        canEncode ? targetBarcode : barcode_widget.Barcode.qrCode();
    final showAsQr = !canEncode || isQr;

    return Screenshot(
      controller: screenshotController,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        width: showAsQr ? 200 : 250,
        height: showAsQr ? 200 : 100,
        alignment: Alignment.center,
        child: barcode_widget.BarcodeWidget(
          barcode: finalBarcode,
          data: cleanData,
          backgroundColor: Colors.white,
          color: Colors.black,
          width: showAsQr ? 180 : 230,
          height: showAsQr ? 180 : 76,
          drawText: !showAsQr,
          errorBuilder: (context, error) {
            return barcode_widget.BarcodeWidget(
              barcode: barcode_widget.Barcode.qrCode(),
              data: cleanData,
              backgroundColor: Colors.white,
              color: Colors.black,
              width: 180,
              height: 180,
              drawText: false,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ScannedResultBloc, ScannedResultState>(
      listenWhen: (prev, current) =>
          current.message != null && prev.message != current.message,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: state.actionStatus == ActionStatus.failure
                  ? theme.colorScheme.error
                  : theme.colorScheme.inverseSurface,
            ),
          );
        }
      },
      child: BlocBuilder<ScannedResultBloc, ScannedResultState>(
        builder: (context, state) {
          final barcode = _extractBarcode(state.scannedModel);
          final rawPayload = _resolveRawPayload(state.scannedModel);
          final displayText = barcode != null
              ? getDisplayValue(barcode)
              : (rawPayload.isNotEmpty ? rawPayload : 'No data found');
          final currentId = state.scannedModel.id;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Scanned Result', style: appBarHeading()),
              actions: [
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, historyState) {
                    final currentRecord = currentId != null
                        ? historyState.getOneData(currentId)
                        : null;

                    final isFavorite = currentRecord != null
                        ? (currentRecord['favorite'] == true)
                        : (state.scannedModel.favorite ?? false);

                    return IconButton(
                      tooltip: isFavorite ? 'Remove Favorite' : 'Save Favorite',
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isFavorite ? Colors.amber : null,
                      ),
                      onPressed: () {
                        final effectiveId = currentId ??
                            DateTime.now().millisecondsSinceEpoch.toString();
                        final effectiveModel =
                            state.scannedModel.copyWith(id: effectiveId);

                        // 1. Persist/toggle in Hive
                        context.read<HistoryBloc>().add(
                              OnFavoriteToggleClicked(effectiveId,
                                  model: effectiveModel),
                            );

                        // 2. Update local ScannedResultBloc state
                        context
                            .read<ScannedResultBloc>()
                            .add(const ToggleFavorite());
                      },
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Barcode / QR Preview Card
                    Center(
                      child: Material(
                        elevation: 2,
                        shadowColor:
                            theme.colorScheme.shadow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: state.screenshotController != null
                              ? _buildBarcodePreview(
                                  screenshotController:
                                      state.screenshotController!,
                                  rawData: rawPayload,
                                  format: barcode?.format ??
                                      state.scannedModel.format ??
                                      BarcodeFormat.qrCode,
                                )
                              : const SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: Center(
                                    child: Icon(Icons.qr_code_2,
                                        size: 80, color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payload Content Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (barcode != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  barcode.format.name.toUpperCase(),
                                  style: defaultTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          AutoSizeText(
                            displayText,
                            minFontSize: 14,
                            maxLines: 8,
                            style: defaultTextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Contextual Action Button
                    if (barcode != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () => context
                              .read<ScannedResultBloc>()
                              .add(OnActionClick(barcode)),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(
                            getButtonText(barcode),
                            style: defaultTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Secondary Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => context
                                .read<ScannedResultBloc>()
                                .add(OnCopyClick(displayText)),
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            label: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () =>
                                context.read<ScannedResultBloc>().add(
                                      OnDownloadClick(
                                        barcode?.displayValue ?? 'Barcode',
                                      ),
                                    ),
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () =>
                                context.read<ScannedResultBloc>().add(
                                      OnShareClick(
                                        value: displayText,
                                        shareImage: context
                                            .read<SettingsBloc>()
                                            .shareQrImage,
                                      ),
                                    ),
                            icon: const Icon(Icons.share_rounded, size: 20),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
