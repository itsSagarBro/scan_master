part of 'scanned_result_bloc.dart';

abstract class ScannedResultEvent {}

class DownloadQrCodeImage extends ScannedResultEvent {}

class OnActionClick extends ScannedResultEvent {
  Barcode barcode;

  OnActionClick(this.barcode);
}

class OnCopyClick extends ScannedResultEvent {
  String value;

  OnCopyClick(this.value);
}

class OnDownloadClick extends ScannedResultEvent {
  String name;

  OnDownloadClick(this.name);
}

class OnShareClick extends ScannedResultEvent {
  String value;
  bool shareImage;

  OnShareClick({required this.value, required this.shareImage});
}

class OnFavortieToggleClick extends ScannedResultEvent {}
