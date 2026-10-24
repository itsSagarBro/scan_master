import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/utils/get_lauch_url.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'scanned_result_event.dart';
part 'scanned_result_state.dart';

class ScannedResultBloc extends Bloc<ScannedResultEvent, ScannedResultState> {
  ScannedResultBloc(ScannedModel scannedModel)
      : super(ScannedResultState.initial(scannedModel)) {
    // Handles contextual actions (Open link, Dial, Wi-Fi Settings)
    on<OnActionClick>((event, emit) async {
      try {
        final rawValue =
            (event.barcode.rawValue ?? event.barcode.displayValue ?? '').trim();

        // 1. UPI Payment Intent
        if (rawValue.toLowerCase().startsWith('upi://pay') ||
            rawValue.toLowerCase().startsWith('upi:')) {
          final upiUri = Uri.parse(rawValue);

          final launched = await launchUrl(
            upiUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );

          if (!launched) {
            final fallbackLaunched = await launchUrl(
              upiUri,
              mode: LaunchMode.externalApplication,
            );

            if (!fallbackLaunched) {
              emit(state.copyWith(
                actionStatus: ActionStatus.failure,
                message: 'No supported UPI app found on this device',
              ));
            }
          }
          return;
        }

        // 2. Wi-Fi: Copy password & open system Wi-Fi settings
        if (event.barcode.type == BarcodeType.wifi) {
          final ssid = event.barcode.wifi?.ssid ?? 'Wi-Fi';
          final password = event.barcode.wifi?.password ?? '';

          if (password.isNotEmpty) {
            await Clipboard.setData(ClipboardData(text: password));
          }

          // Open Android Wi-Fi settings screen or generic settings fallback
          final wifiSettingsUri =
              Uri.parse('package:android.settings.WIFI_SETTINGS');
          final fallbackSettingsUri =
              Uri.parse('package:android.settings.SETTINGS');

          bool opened = false;
          try {
            if (await canLaunchUrl(wifiSettingsUri)) {
              opened = await launchUrl(wifiSettingsUri);
            }
          } catch (_) {}

          if (!opened) {
            try {
              if (await canLaunchUrl(fallbackSettingsUri)) {
                opened = await launchUrl(fallbackSettingsUri);
              }
            } catch (_) {}
          }

          if (password.isNotEmpty) {
            emit(state.copyWith(
              actionStatus: ActionStatus.success,
              message:
                  'Password copied for "$ssid". Select it in settings to connect.',
            ));
          } else {
            emit(state.copyWith(
              actionStatus: ActionStatus.success,
              message: 'Opening Wi-Fi settings for "$ssid"...',
            ));
          }
          return;
        }

        // 3. Web URL, Maps, Dial, Email, or Web Search fallback
        final rawUrl = getLaunchUrl(event.barcode);
        final uri = Uri.tryParse(rawUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          emit(state.copyWith(
            actionStatus: ActionStatus.failure,
            message: 'Cannot launch this action',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          actionStatus: ActionStatus.failure,
          message: 'Action failed: $e',
        ));
      }
    });

    // Automates downloading QR when configured in settings
    on<DownloadQrCodeImage>((event, emit) async {
      final name =
          state.scannedModel.name ?? state.scannedModel.rawValue ?? 'QR_Code';
      add(OnDownloadClick(name));
    });

    // Captures barcode screenshot and saves to gallery via Gal
    on<OnDownloadClick>((event, emit) async {
      try {
        final imageBytes = await state.screenshotController?.capture();
        if (imageBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final cleanName = event.name
              .replaceAll(RegExp(r'[^\w\s\.-]'), '_')
              .replaceAll(' ', '_');
          final file = File(
            '${tempDir.path}/scan_master_${cleanName}_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await file.writeAsBytes(imageBytes);

          // Save to device photo gallery
          await Gal.putImage(file.path);

          emit(state.copyWith(
            actionStatus: ActionStatus.success,
            message: 'QR code saved to gallery',
          ));
        } else {
          emit(state.copyWith(
            actionStatus: ActionStatus.failure,
            message: 'Failed to capture QR image',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          actionStatus: ActionStatus.failure,
          message: 'Error saving image: $e',
        ));
      }
    });

    // Shares text or rendered QR code image via SharePlus
    on<OnShareClick>((event, emit) async {
      try {
        if (event.shareImage) {
          final imageBytes = await state.screenshotController?.capture();

          if (imageBytes != null) {
            final tempDir = await getTemporaryDirectory();
            final filePath =
                '${tempDir.path}/ScanMaster_Share_${DateTime.now().millisecondsSinceEpoch}.png';
            final file = File(filePath);
            await file.writeAsBytes(imageBytes);

            final params = ShareParams(
              text: event.value,
              subject: 'Scanned Code',
              files: [
                XFile(
                  file.path,
                  mimeType: 'image/png',
                  name: 'ScanMaster_Code.png',
                ),
              ],
            );

            await SharePlus.instance.share(params);
          } else {
            final params = ShareParams(
              text: event.value,
              subject: 'Scanned Code',
            );

            await SharePlus.instance.share(params);
          }
        } else {
          final params = ShareParams(
            text: event.value,
            subject: 'Scanned Code',
          );

          await SharePlus.instance.share(params);
        }
      } catch (e) {
        emit(state.copyWith(
          actionStatus: ActionStatus.failure,
          message: 'Unable to share: $e',
        ));
      }
    });

    // Copies plain text to clipboard
    on<OnCopyClick>((event, emit) async {
      await Clipboard.setData(ClipboardData(text: event.value));
      emit(state.copyWith(
        actionStatus: ActionStatus.success,
        message: 'Copied to clipboard',
      ));
    });

    on<ToggleFavorite>((event, emit) {
      final current = state.scannedModel;
      final toggled = !(current.favorite ?? false);
      emit(state.copyWith(
        scannedModel: current.copyWith(favorite: toggled),
        message: toggled ? 'Added to favorites' : 'Removed from favorites',
        actionStatus: ActionStatus.success,
      ));
    });
  }
}
