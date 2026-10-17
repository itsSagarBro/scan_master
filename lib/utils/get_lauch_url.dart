import 'package:mobile_scanner/mobile_scanner.dart';

String getLaunchUrl(Barcode barcode) {
  String url = "";
  switch (barcode.type) {
    case BarcodeType.email:
      url = _getLaunchFromEmail(barcode);
      break;
    case BarcodeType.contactInfo:
      url = _getTextFromPhone(barcode);
      break;
    case BarcodeType.sms:
      url = _getLaunchFromSms(barcode);
      break;
    case BarcodeType.phone:
      url = _getTextFromPhone(barcode);
      break;
    case BarcodeType.wifi:
      url = _getTextFromWifi(barcode);
      break;
    default:
      url = barcode.url?.url ??
          "https://www.google.com/search?q=${barcode.displayValue}";
      break;
  }
  return url;
}

String _getLaunchFromEmail(Barcode barcode) {
  String url = "";

  if (barcode.email != null) {
    url = "mailto:${barcode.email!.address}";

    if (barcode.email?.subject != null) {
      url += "?subject=${barcode.email?.subject}";
    }

    if (barcode.email?.body != null) {
      url += "&body=${barcode.email?.body}";
    }
  }

  return url;
}

String _getLaunchFromSms(Barcode barcode) {
  String text = "";

  if (barcode.sms != null) {
    text = "sms:${barcode.sms!.phoneNumber}";

    if (barcode.sms?.message != null) {
      text += "?body=${barcode.sms?.message}";
    }
  }

  return text;
}

String _getTextFromPhone(Barcode barcode) {
  return "tel:${barcode.contactInfo?.phones[0].number.toString()}";
}

String _getTextFromWifi(Barcode barcode) {
  String text = "";

  if (barcode.wifi != null) {
    text = "SSID: ${barcode.wifi!.ssid}";

    if (barcode.wifi?.password != null) {
      text += "\nPassword: ${barcode.wifi?.password}";
    }

    if (barcode.wifi?.encryptionType != null) {
      String type = "";

      switch (barcode.wifi?.encryptionType) {
        case EncryptionType.unknown:
          type = "NONE";
          break;
        case EncryptionType.wep:
          type = "WEP";
          break;
        case EncryptionType.wpa:
          type = "WPA";
          break;
        case EncryptionType.open:
          type = "OPEN";
          break;
        default:
      }

      text += "\nType: $type";
    }
  }

  return text;
}
