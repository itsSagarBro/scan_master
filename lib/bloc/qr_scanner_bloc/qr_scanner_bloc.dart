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
      emit(state.copyWith(flashOn: flashOn, clearData: true));
    });

    on<OnScannedData>((event, emit) {
      if (!scanned) {
        scanned = true;

        ScannedModel? scannedModel;

        if (event.data is ScannedModel) {
          scannedModel = event.data as ScannedModel;
        } else if (event.data is BarcodeCapture) {
          final capture = event.data as BarcodeCapture;
          if (capture.barcodes.isNotEmpty) {
            final first = capture.barcodes.first;
            scannedModel = ScannedModel.fromBarcode(
              first,
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            );
          }
        }

        if (scannedModel != null) {
          emit(state.copyWith(flashOn: flashOn, data: scannedModel));
        } else {
          scanned = false;
        }
      }
    });

    on<OnReturn>((event, emit) async {
      emit(state.copyWith(flashOn: false, clearData: true));

      if (scanned && !event.fromBackground) {
        await Future.delayed(const Duration(milliseconds: 500));
        scanned = false;
        startScannerController();
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
      }
      emit(state.copyWith(flashOn: false, clearData: true));
    });

    on<OnScanImageFromGallery>((event, emit) async {
      try {
        final capture =
            await state.mobileScannerController?.analyzeImage(event.imagePath);

        if (capture != null && capture.barcodes.isNotEmpty) {
          final first = capture.barcodes.first;
          final scannedModel = ScannedModel.fromBarcode(
            first,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          );

          scanned = true;
          emit(state.copyWith(flashOn: flashOn, data: scannedModel));
        } else {
          emit(state.copyWith(flashOn: flashOn, clearData: true));
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
