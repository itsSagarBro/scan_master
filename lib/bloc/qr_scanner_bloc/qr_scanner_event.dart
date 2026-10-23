part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent {}

final class OnFlashClick extends QrScannerEvent {}

final class OnScannedData extends QrScannerEvent {
  BarcodeCapture data;

  OnScannedData(this.data);
}

final class OnReturn extends QrScannerEvent {
  bool fromBackground;

  OnReturn({this.fromBackground = false});
}

final class PauseCamera extends QrScannerEvent {}

final class StartCamera extends QrScannerEvent {}

final class OnScanImageFromGallery extends QrScannerEvent {
  final String imagePath;
  OnScanImageFromGallery(this.imagePath);
}
