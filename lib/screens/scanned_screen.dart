import 'dart:ui';

import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:scan_master/utils/resolve_barcode_type.dart';
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
      } else if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }
    return '';
  }

  Barcode? _extractBarcode(ScannedModel model) {
    final payload = _resolveRawPayload(model);

    Barcode? originalBarcode;
    final rawData = model.raw;
    if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      try {
        originalBarcode = Barcode.fromNative(
          Map<Object?, Object?>.from(rawData.first as Map),
        );
      } catch (_) {}
    } else if (rawData is Barcode) {
      originalBarcode = rawData;
    }

    if (payload.isNotEmpty) {
      final resolvedType = resolveBarcodeType(
        payload,
        originalBarcode?.type ?? model.type,
      );

      WiFi? wifiData = originalBarcode?.wifi;
      if (resolvedType == BarcodeType.wifi && wifiData == null) {
        wifiData = _parseWifiString(payload);
      }

      return Barcode(
        rawValue: payload,
        displayValue: model.name ?? payload,
        format: originalBarcode?.format ?? model.format ?? BarcodeFormat.qrCode,
        type: resolvedType,
        wifi: wifiData,
        url: (resolvedType == BarcodeType.url)
            ? (originalBarcode?.url ?? UrlBookmark(url: payload, title: ''))
            : null,
      );
    }

    return originalBarcode;
  }

  WiFi? _parseWifiString(String raw) {
    try {
      final clean = raw.trim();
      final ssidMatch = RegExp(r'S:(.*?)(?:;|$)').firstMatch(clean);
      final passMatch = RegExp(r'P:(.*?)(?:;|$)').firstMatch(clean);
      final typeMatch = RegExp(r'T:(.*?)(?:;|$)').firstMatch(clean);

      final ssid = ssidMatch?.group(1) ?? '';
      final password = passMatch?.group(1) ?? '';
      final typeStr = (typeMatch?.group(1) ?? 'WPA').toUpperCase();

      EncryptionType enc = EncryptionType.wpa;
      if (typeStr == 'WEP') {
        enc = EncryptionType.wep;
      } else if (typeStr == 'NOPASS' || typeStr.isEmpty) {
        enc = EncryptionType.open;
      }

      return WiFi(
        ssid: ssid,
        password: password,
        encryptionType: enc,
      );
    } catch (_) {
      return null;
    }
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
        width: showAsQr ? 190 : 250,
        height: showAsQr ? 190 : 100,
        alignment: Alignment.center,
        child: barcode_widget.BarcodeWidget(
          barcode: finalBarcode,
          data: cleanData,
          backgroundColor: Colors.white,
          color: Colors.black,
          width: showAsQr ? 170 : 230,
          height: showAsQr ? 170 : 76,
          drawText: !showAsQr,
          errorBuilder: (context, error) {
            return barcode_widget.BarcodeWidget(
              barcode: barcode_widget.Barcode.qrCode(),
              data: cleanData,
              backgroundColor: Colors.white,
              color: Colors.black,
              width: 170,
              height: 170,
              drawText: false,
            );
          },
        ),
      ),
    );
  }

  IconData _getTypeIcon(BarcodeType? type) {
    return switch (type) {
      BarcodeType.url => Icons.link_rounded,
      BarcodeType.wifi => Icons.wifi_rounded,
      BarcodeType.phone => Icons.call_rounded,
      BarcodeType.sms => Icons.sms_outlined,
      BarcodeType.email => Icons.email_outlined,
      BarcodeType.contactInfo => Icons.person_outline_rounded,
      BarcodeType.geo => Icons.location_on_outlined,
      _ => Icons.qr_code_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

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
                borderRadius: BorderRadius.circular(14),
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

          final formatName = (barcode?.format ??
                  state.scannedModel.format ??
                  BarcodeFormat.qrCode)
              .name
              .toUpperCase();
          final typeName =
              (barcode?.type ?? state.scannedModel.type ?? BarcodeType.text)
                  .name
                  .toUpperCase();

          return Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.22),
                          theme.colorScheme.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.2,
                  left: -80,
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.tertiary.withValues(alpha: 0.16),
                          theme.colorScheme.tertiary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: const SizedBox.expand(),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 76, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.14),
                                  blurRadius: 36,
                                  offset: const Offset(0, 16),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getTypeIcon(barcode?.type ??
                                        state.scannedModel.type),
                                    size: 14,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    typeName,
                                    style: defaultTextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                formatName,
                                style: defaultTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RESULT DATA',
                                        style: defaultTextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          context
                                              .read<ScannedResultBloc>()
                                              .add(OnCopyClick(displayText));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.copy_rounded,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    displayText,
                                    style: defaultTextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (barcode != null) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context
                                    .read<ScannedResultBloc>()
                                    .add(OnActionClick(barcode));
                              },
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 20),
                              label: Text(
                                getButtonText(barcode),
                                style: defaultTextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryActionButton(
                                theme: theme,
                                icon: Icons.copy_rounded,
                                label: 'Copy',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<ScannedResultBloc>()
                                      .add(OnCopyClick(displayText));
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSecondaryActionButton(
                                theme: theme,
                                icon: Icons.download_rounded,
                                label: 'Save',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.read<ScannedResultBloc>().add(
                                        OnDownloadClick(
                                          barcode?.displayValue ?? 'Barcode',
                                        ),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSecondaryActionButton(
                                theme: theme,
                                icon: Icons.share_rounded,
                                label: 'Share',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.read<ScannedResultBloc>().add(
                                        OnShareClick(
                                          value: displayText,
                                          shareImage: context
                                              .read<SettingsBloc>()
                                              .shareQrImage,
                                        ),
                                      );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleIconButton(
                            theme: theme,
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Back',
                            onTap: () => context.pop(),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 9),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: Text(
                                  'Scan Result',
                                  style: defaultTextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          BlocBuilder<HistoryBloc, HistoryState>(
                            builder: (context, historyState) {
                              final currentRecord = currentId != null
                                  ? historyState.getOneData(currentId)
                                  : null;

                              final isFavorite = currentRecord != null
                                  ? (currentRecord['favorite'] == true)
                                  : (state.scannedModel.favorite ?? false);

                              return _buildCircleIconButton(
                                theme: theme,
                                icon: isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                iconColor: isFavorite
                                    ? Colors.amber
                                    : theme.colorScheme.onSurface,
                                tooltip: isFavorite
                                    ? 'Remove Favorite'
                                    : 'Save Favorite',
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  final effectiveId = currentId ??
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                  final effectiveModel = state.scannedModel
                                      .copyWith(id: effectiveId);

                                  context.read<HistoryBloc>().add(
                                        OnFavoriteToggleClicked(effectiveId,
                                            model: effectiveModel),
                                      );
                                  context
                                      .read<ScannedResultBloc>()
                                      .add(const ToggleFavorite());
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleIconButton({
    required ThemeData theme,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.72),
          shape: const CircleBorder(
            side: BorderSide(
              color: Colors.white12,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Tooltip(
                message: tooltip,
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: defaultTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
