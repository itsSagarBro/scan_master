import 'package:mobile_scanner/mobile_scanner.dart';

/// Returns the contextual action button label based on detected [Barcode].
String getButtonText(Barcode barcode) {
  final raw =
      (barcode.rawValue ?? barcode.displayValue ?? '').toLowerCase().trim();

  // Check if payload is a UPI payment link
  if (raw.startsWith('upi://pay') || raw.startsWith('upi:')) {
    return 'Pay via UPI';
  }

  return switch (barcode.type) {
    BarcodeType.email => 'Send Email',
    BarcodeType.contactInfo => 'Save Contact',
    BarcodeType.sms => 'Send SMS',
    BarcodeType.phone => 'Call Now',
    BarcodeType.wifi => 'Copy Password & Open Wi-Fi',
    BarcodeType.url => 'Open in Browser',
    BarcodeType.geo => 'Open in Maps',
    _ => 'Web Search',
  };
}
