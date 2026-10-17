import 'package:mobile_scanner/mobile_scanner.dart';

/// returns the contextual action button label based on the detected [Barcode.type].
///
/// maps known payload types like urls, contacts, or wi-fi credentials to their
/// respective call-to-action labels, defaulting to "Web Search" for generic raw values.
String getButtonText(Barcode barcode) {
  return switch (barcode.type) {
    BarcodeType.email => 'Send Email',
    BarcodeType.contactInfo => 'Save Contact',
    BarcodeType.sms => 'Send SMS',
    BarcodeType.phone => 'Call Now',
    BarcodeType.wifi => 'Connect Now',
    BarcodeType.url => 'Open in browser',
    BarcodeType.geo => 'Open in map',
    _ => 'Web Search',
  };
}
