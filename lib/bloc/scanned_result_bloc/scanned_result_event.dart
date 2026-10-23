part of 'scanned_result_bloc.dart';

sealed class ScannedResultEvent {
  const ScannedResultEvent();
}

final class DownloadQrCodeImage extends ScannedResultEvent {
  const DownloadQrCodeImage();
}

final class OnActionClick extends ScannedResultEvent {
  final Barcode barcode;
  const OnActionClick(this.barcode);
}

final class OnCopyClick extends ScannedResultEvent {
  final String value;
  const OnCopyClick(this.value);
}

final class OnDownloadClick extends ScannedResultEvent {
  final String name;
  const OnDownloadClick(this.name);
}

final class OnShareClick extends ScannedResultEvent {
  final String value;
  final bool shareImage;

  const OnShareClick({
    required this.value,
    required this.shareImage,
  });
}
