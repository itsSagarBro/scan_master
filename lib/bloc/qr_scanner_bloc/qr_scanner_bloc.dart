import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/models/history_model.dart';

part 'qr_scanner_event.dart';
part 'qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  QrScannerBloc() : super(QrScannerState.initial()) {
    on<OnFlashClick>((event, emit) async {
      flashOn = !flashOn;
      await state.mobileScannerController?.toggleTorch();
      emit(state.copyWith(flashOn: flashOn, data: null));
    });

    on<OnScannedData>((event, emit) {
      if (!scanned) {
        state.mobileScannerController?.stop();
        scanned = true;
        String id = DateTime.now().millisecondsSinceEpoch.toString();
        ScannedModel scannedModel = ScannedModel(
            id: id,
            name: event.data.barcodes[0].displayValue,
            datetime: DateTime.now().toString(),
            favorite: false,
            raw: event.data.raw);
        emit(state.copyWith(flashOn: flashOn, data: scannedModel));
      }
    });

    on<OnReturn>((event, emit) async {
      if (scanned && !event.fromBackground) {
        scanned = false;
        startScannerController();
      }
      if (flashOn) {
        flashOn = false;
        emit(state.copyWith(flashOn: flashOn, data: null));
      }
    });

    on<PauseCamera>((event, emit) {
      state.mobileScannerController?.stop();
      scanned = true;
    });

    on<StartCamera>((event, emit) {
      startScannerController();
      scanned = false;
      if (flashOn) {
        flashOn = false;
        emit(state.copyWith(flashOn: flashOn, data: null));
      }
    });

    on<OnScanImageFromGallery>((event, emit) async {
      try {
        final capture =
            await state.mobileScannerController?.analyzeImage(event.imagePath);

        if (capture != null && capture.barcodes.isNotEmpty) {
          final first = capture.barcodes.first;
          final payload = first.rawValue ?? first.displayValue ?? '';

          if (payload.isNotEmpty) {
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            final scannedModel = ScannedModel(
              id: id,
              name: first.displayValue ?? payload,
              datetime: DateTime.now().toIso8601String(),
              favorite: false,
              rawValue: payload,
              format: first.format,
              type: first.type,
              raw: capture.raw,
            );

            emit(state.copyWith(flashOn: flashOn, data: scannedModel));
          }
        } else {
          // Trigger return/reset so UI can notify no QR found
          emit(state.copyWith(flashOn: flashOn, data: null));
        }
      } catch (e) {
        Logger().e('Error scanning from gallery: $e');
      }
    });
  }

  bool flashOn = false;
  bool scanned = false;

  void startScannerController() {
    try {
      state.mobileScannerController?.start();
    } catch (e) {
      Logger().d(e.toString());
    }
  }

  @override
  Future<void> close() {
    state.dispose();
    return super.close();
  }
}
