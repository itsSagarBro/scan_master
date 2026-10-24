part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent {}

final class OnFlashClick extends QrScannerEvent {}

final class OnScannedData extends QrScannerEvent {
  final dynamic data; // Accepts BarcodeCapture or ScannedModel

  OnScannedData(this.data);
}

final class OnReturn extends QrScannerEvent {
  final bool fromBackground;

  OnReturn({this.fromBackground = false});
}

final class PauseCamera extends QrScannerEvent {}

final class StartCamera extends QrScannerEvent {}

final class OnScanImageFromGallery extends QrScannerEvent {
  final String imagePath;
  OnScanImageFromGallery(this.imagePath);
}
