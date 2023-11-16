import 'package:mobile_scanner/mobile_scanner.dart';

String getDisplayValue(Barcode barcode) {
  String text = "";
  switch (barcode.type) {
    case BarcodeType.email:
      text = _getTextFromEmail(barcode);
      break;
    case BarcodeType.contactInfo:
      text = _getTextFromContact(barcode);
      break;
    case BarcodeType.sms:
      text = _getTextFromSms(barcode);
      break;
    case BarcodeType.url:
      text = _getTextFromUrl(barcode);
      break;
    case BarcodeType.phone:
      text = _getTextFromPhone(barcode);
      break;
    case BarcodeType.wifi:
      text = _getTextFromWifi(barcode);
      break;
    default:
      text = barcode.displayValue ?? "Unknown";
      break;
  }
  return text;
}

String _getTextFromEmail(Barcode barcode) {
  String text = "";

  if (barcode.email != null) {
    text = "Address: ${barcode.email!.address ?? "No Address"}";

    if (barcode.email?.subject != null) {
      text += "\nSubject: ${barcode.email?.subject}";
    }

    if (barcode.email?.body != null) {
      text += "\nBody: ${barcode.email?.body}";
    }
  }

  return text;
}

String _getTextFromContact(Barcode barcode) {
  String text = "";

  if (barcode.contactInfo != null) {
    if (barcode.contactInfo?.name != null) {
      text = "Name: ${barcode.contactInfo!.name?.formattedName}\n";
    }

    if (barcode.contactInfo?.phones != null) {
      text += "Phone: ";

      int completedPhone = 0;

      for (var phone in barcode.contactInfo!.phones) {
        text += "${phone.number}${completedPhone > 0 ? ", " : ""}";
        completedPhone++;
      }
    }
  }

  return text;
}

String _getTextFromSms(Barcode barcode) {
  String text = "";

  if (barcode.sms != null) {
    text = "Phone: ${barcode.sms!.phoneNumber}";

    if (barcode.sms?.message != null) {
      text += "\nMessage: ${barcode.sms?.message}";
    }
  }

  return text;
}

String _getTextFromUrl(Barcode barcode) {
  String text = "";

  if (barcode.url != null) {
    if ((barcode.url?.title ?? "").isNotEmpty) {
      text = "Title: ${barcode.url!.title}\n";
    }

    text += "Url: ${barcode.url?.url}";
  }

  return text;
}

String _getTextFromPhone(Barcode barcode) {
  String text = "";

  if (barcode.phone != null) {
    text = "Phone: ${barcode.phone?.number}";
  }

  return text;
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
        case EncryptionType.none:
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
