part of 'qr_scanner_bloc.dart';

class QrScannerState {
  QrScannerState._(
      {required this.mobileScannerController,
      required this.flashOn,
      required this.data});

  final MobileScannerController? mobileScannerController;
  final bool? flashOn;
  final ScannedModel? data;

  factory QrScannerState.initial() {
    MobileScannerController controller =
        MobileScannerController(detectionSpeed: DetectionSpeed.normal);
    return QrScannerState._(
        mobileScannerController: controller, flashOn: false, data: null);
  }

  QrScannerState copyWith({bool? flashOn, ScannedModel? data}) {
    return QrScannerState._(
        mobileScannerController: mobileScannerController,
        flashOn: flashOn ?? this.flashOn,
        data: data);
  }

  void dispose() {
    mobileScannerController?.dispose();
  }
}
