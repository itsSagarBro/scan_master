part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent {}

final class OnFlashClick extends QrScannerEvent {}

final class OnScannedData extends QrScannerEvent {
  BarcodeCapture data;

  OnScannedData(this.data);
}

final class OnReturnFromScanned extends QrScannerEvent {}
