import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
        scanned = true;
        Box history = Hive.box("history");
        String id = DateTime.now().millisecondsSinceEpoch.toString();
        ScannedModel scannedModel = ScannedModel(
            id: id,
            name: event.data.barcodes[0].displayValue,
            datetime: DateTime.now().toString(),
            favorite: false,
            raw: event.data.raw);
        history.put(id, scannedModel.toJson());
        emit(state.copyWith(flashOn: flashOn, data: scannedModel));
      }
    });

    on<OnReturn>((event, emit) async {
      flashOn = false;
      scanned = false;
      emit(state.copyWith(flashOn: flashOn, data: null));
    });

    on<PauseCamera>((event, emit) {
      scanned = true;
    });

    on<StartCamera>((event, emit) {
      scanned = false;
    });
  }

  bool flashOn = false;
  bool scanned = false;

  @override
  Future<void> close() {
    state.dispose();
    return super.close();
  }
}
