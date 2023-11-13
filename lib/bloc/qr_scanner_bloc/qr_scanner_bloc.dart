import 'package:bloc/bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        scanned = true;
        state.mobileScannerController?.stop();
        emit(state.copyWith(flashOn: flashOn, data: event.data));
      }
    });

    on<OnReturnFromScanned>((event, emit) async {
      await state.mobileScannerController?.start();
      emit(state.copyWith(flashOn: flashOn, data: null));

      if (flashOn) {
        state.mobileScannerController?.toggleTorch();
      }

      scanned = false;
    });
  }

  bool flashOn = false;
  bool scanned = false;

  @override
  Future<void> close() {
    state.mobileScannerController?.dispose();
    return super.close();
  }
}
