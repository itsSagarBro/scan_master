part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent {}

final class OnFlashClick extends QrScannerEvent {}

final class OnScannedData extends QrScannerEvent {
  BarcodeCapture data;

  OnScannedData(this.data);
}

final class OnReturn extends QrScannerEvent {
  bool? startCamera;
  OnReturn({this.startCamera});
}
