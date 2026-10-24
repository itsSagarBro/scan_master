import 'package:mobile_scanner/mobile_scanner.dart';

/// Detects the accurate BarcodeType even if ML Kit returned BarcodeType.text/unknown
BarcodeType resolveBarcodeType(String payload, [BarcodeType? existingType]) {
  final clean = payload.trim();
  final lower = clean.toLowerCase();

  // 1. Wi-Fi
  if (lower.startsWith('wifi:') || lower.startsWith('wpa:')) {
    return BarcodeType.wifi;
  }

  // 2. UPI / Payments
  if (lower.startsWith('upi://') || lower.startsWith('upi:')) {
    return BarcodeType.url; // Or handle as URL for intent launching
  }

  // 3. Web URLs
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('www.') ||
      RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$').hasMatch(clean)) {
    return BarcodeType.url;
  }

  // 4. Contact / vCard / MeCard
  if (lower.startsWith('begin:vcard') ||
      lower.startsWith('mecard:') ||
      lower.startsWith('bizcard:')) {
    return BarcodeType.contactInfo;
  }

  // 5. Telephone
  if (lower.startsWith('tel:') ||
      (RegExp(r'^\+?[0-9]{7,15}$').hasMatch(clean.replaceAll(' ', '')) &&
          existingType == BarcodeType.phone)) {
    return BarcodeType.phone;
  }

  // 6. SMS
  if (lower.startsWith('sms:') || lower.startsWith('smsto:')) {
    return BarcodeType.sms;
  }

  // 7. Email
  if (lower.startsWith('mailto:') ||
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(clean)) {
    return BarcodeType.email;
  }

  // 8. Geo Location
  if (lower.startsWith('geo:')) {
    return BarcodeType.geo;
  }

  // Return existing detected type if valid and not generic text
  if (existingType != null &&
      existingType != BarcodeType.text &&
      existingType != BarcodeType.unknown) {
    return existingType;
  }

  return BarcodeType.text;
}
