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
    default:
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
      text = "Name: ${barcode.contactInfo!.name}\n";
    }

    if (barcode.contactInfo?.phones != null) {
      text += "Number: ";

      for (var phone in barcode.contactInfo!.phones) {
        text += "${phone.number}, ";
      }
    }
  }

  return text;
}

String _getTextFromSms(Barcode barcode) {
  String text = "";

  if (barcode.sms != null) {
    "Phone: ${barcode.sms!.phoneNumber}";

    if (barcode.sms?.message != null) {
      text += "\nMessage: ${barcode.sms?.message}";
    }
  }

  return text;
}

String _getTextFromUrl(Barcode barcode) {
  String text = "";

  if (barcode.url != null) {
    if (barcode.url?.title != null) {
      text = "Title: ${barcode.url!.title}\n";
    }

    text += "Url: ${barcode.url?.url}";
  }

  return text;
}
