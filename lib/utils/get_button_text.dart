import 'package:mobile_scanner/mobile_scanner.dart';

String getButtonText(Barcode barcode) {
  String text = "";
  switch (barcode.type) {
    case BarcodeType.email:
      text = "Send Email";
      break;
    case BarcodeType.contactInfo:
      text = "Call Now";
      break;
    case BarcodeType.sms:
      text = "Send SMS";
      break;
    case BarcodeType.phone:
      text = "Call Now";
      break;
    case BarcodeType.wifi:
      text = "Connect Now";
      break;
    case BarcodeType.url:
      text = "Open in browser";
      break;
    case BarcodeType.geo:
      text = "Open in map";
      break;
    default:
      text = "Web Search";
      break;
  }
  return text;
}
