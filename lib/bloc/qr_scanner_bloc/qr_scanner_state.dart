part of 'qr_scanner_bloc.dart';

class QrScannerState {
  QrScannerState._({
    required this.mobileScannerController,
    required this.flashOn,
    required this.data,
  });

  final MobileScannerController? mobileScannerController;
  final bool? flashOn;
  final ScannedModel? data;

  factory QrScannerState.initial() {
    final controller =
        MobileScannerController(detectionSpeed: DetectionSpeed.normal);
    return QrScannerState._(
      mobileScannerController: controller,
      flashOn: false,
      data: null,
    );
  }

  QrScannerState copyWith({
    bool? flashOn,
    ScannedModel? data,
    bool clearData = false,
  }) {
    return QrScannerState._(
      mobileScannerController: mobileScannerController,
      flashOn: flashOn ?? this.flashOn,
      data: clearData ? null : (data ?? this.data),
    );
  }

  void dispose() {
    mobileScannerController?.dispose();
  }
}
