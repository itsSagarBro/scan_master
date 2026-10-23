import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:mobile_scanner/mobile_scanner.dart';

/// maps a [BarcodeFormat] detected by mobile scanner to its corresponding
/// renderable [barcode_widget.Barcode] instance.
///
/// falls back to a standard qr code if the format is unsupported or unrecognized.
barcode_widget.Barcode getQrType(BarcodeFormat format) {
  return switch (format) {
    BarcodeFormat.aztec => barcode_widget.Barcode.aztec(),
    BarcodeFormat.codabar => barcode_widget.Barcode.codabar(),
    BarcodeFormat.code128 => barcode_widget.Barcode.code128(),
    BarcodeFormat.code39 => barcode_widget.Barcode.code39(),
    BarcodeFormat.code93 => barcode_widget.Barcode.code93(),
    BarcodeFormat.dataMatrix => barcode_widget.Barcode.dataMatrix(),
    BarcodeFormat.ean13 => barcode_widget.Barcode.ean13(),
    BarcodeFormat.ean8 => barcode_widget.Barcode.ean8(),
    BarcodeFormat.itf14 => barcode_widget.Barcode.itf(),
    BarcodeFormat.pdf417 => barcode_widget.Barcode.pdf417(),
    BarcodeFormat.upcA => barcode_widget.Barcode.upcA(),
    BarcodeFormat.upcE => barcode_widget.Barcode.upcE(),
    _ => barcode_widget.Barcode.qrCode(),
  };
}
