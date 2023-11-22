import 'package:barcode_widget/barcode_widget.dart' as barcode_widget;
import 'package:mobile_scanner/mobile_scanner.dart';

barcode_widget.Barcode getQrType(BarcodeFormat format) {
  barcode_widget.Barcode barcode = barcode_widget.Barcode.qrCode();

  switch (format) {
    case BarcodeFormat.aztec:
      barcode = barcode_widget.Barcode.aztec();
      break;
    case BarcodeFormat.codabar:
      barcode = barcode_widget.Barcode.codabar();
      break;
    case BarcodeFormat.code128:
      barcode = barcode_widget.Barcode.code128();
      break;
    case BarcodeFormat.code39:
      barcode = barcode_widget.Barcode.code39();
      break;
    case BarcodeFormat.code93:
      barcode = barcode_widget.Barcode.code93();
      break;
    case BarcodeFormat.dataMatrix:
      barcode = barcode_widget.Barcode.dataMatrix();
      break;
    case BarcodeFormat.ean13:
      barcode = barcode_widget.Barcode.ean13();
      break;
    case BarcodeFormat.ean8:
      barcode = barcode_widget.Barcode.ean8();
      break;
    case BarcodeFormat.itf:
      barcode = barcode_widget.Barcode.itf();
      break;
    case BarcodeFormat.pdf417:
      barcode = barcode_widget.Barcode.pdf417();
      break;
    case BarcodeFormat.upcA:
      barcode = barcode_widget.Barcode.upcA();
      break;
    case BarcodeFormat.upcE:
      barcode = barcode_widget.Barcode.upcE();
      break;
    default:
      barcode = barcode_widget.Barcode.qrCode();
      break;
  }

  return barcode;
}
