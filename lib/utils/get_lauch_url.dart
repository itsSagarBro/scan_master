import 'package:mobile_scanner/mobile_scanner.dart';

String getLaunchUrl(Barcode barcode) {
  final raw = (barcode.rawValue ?? barcode.displayValue ?? '').trim();

  // If already a UPI or standard scheme URI, return directly
  if (raw.toLowerCase().startsWith('upi://') ||
      raw.toLowerCase().startsWith('upi:')) {
    return raw;
  }

  switch (barcode.type) {
    case BarcodeType.email:
      return _getLaunchFromEmail(barcode);
    case BarcodeType.contactInfo:
      return _getTextFromPhone(barcode);
    case BarcodeType.sms:
      return _getLaunchFromSms(barcode);
    case BarcodeType.phone:
      return _getTextFromPhone(barcode);
    case BarcodeType.wifi:
      return _getTextFromWifi(barcode);
    default:
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return raw;
      }
      return 'https://www.google.com/search?q=${Uri.encodeComponent(raw)}';
  }
}

String _getLaunchFromEmail(Barcode barcode) {
  if (barcode.email != null) {
    final addr = barcode.email!.address ?? '';
    final subject = barcode.email?.subject != null
        ? '?subject=${barcode.email!.subject}'
        : '';
    return 'mailto:$addr$subject';
  }
  return '';
}

String _getLaunchFromSms(Barcode barcode) {
  if (barcode.sms != null) {
    return 'sms:${barcode.sms!.phoneNumber}';
  }
  return '';
}

String _getTextFromPhone(Barcode barcode) {
  if (barcode.phone != null) {
    return 'tel:${barcode.phone!.number}';
  }
  if (barcode.contactInfo?.phones.isNotEmpty ?? false) {
    return 'tel:${barcode.contactInfo!.phones.first.number}';
  }
  return '';
}

String _getTextFromWifi(Barcode barcode) => '';
