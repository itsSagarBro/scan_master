import 'package:mobile_scanner/mobile_scanner.dart';

/// Data model representing a scanned barcode or QR record stored in persistent storage
class ScannedModel {
  /// Unique identifier for the scan entry, typically a timestamp or UUID
  final String? id;

  /// Human-readable display name or title for the record
  final String? name;

  /// ISO-8601 formatted timestamp string representing when the scan occurred
  final String? datetime;

  /// Indicates whether the user marked this scan entry as a favorite
  final bool? favorite;

  /// Decoded raw string payload of the barcode (e.g., URL, text, Wi-Fi string)
  final String? rawValue;

  /// Detected symbology (e.g., qrCode, ean13, code128)
  final BarcodeFormat? format;

  /// Semantic content type (e.g., url, wifi, contactInfo, sms)
  final BarcodeType? type;

  /// Underlying raw payload preserved for backwards compatibility with legacy records
  final dynamic raw;

  const ScannedModel({
    this.id,
    this.name,
    this.datetime,
    this.favorite,
    this.rawValue,
    this.format,
    this.type,
    this.raw,
  });

  /// Creates a [ScannedModel] from persistent storage or a JSON map,
  /// with automatic fallback type resolution.
  factory ScannedModel.fromJson(Map<dynamic, dynamic> json) {
    final rawVal = json['rawValue'] as String?;
    final nameVal = json['name'] as String?;

    BarcodeType? parsedType = json['type'] != null
        ? BarcodeType.values.asNameMap()[json['type']]
        : null;

    // Resolve accurate type if persisted type is missing or generic text/unknown
    if (parsedType == null ||
        parsedType == BarcodeType.text ||
        parsedType == BarcodeType.unknown) {
      final payloadToInspect = rawVal ?? nameVal ?? '';
      if (payloadToInspect.trim().isNotEmpty) {
        parsedType = resolveBarcodeType(payloadToInspect, parsedType);
      }
    }

    return ScannedModel(
      id: json['id'] as String?,
      name: nameVal,
      datetime: json['datetime'] as String?,
      favorite: json['favorite'] as bool?,
      rawValue: rawVal,
      format: json['format'] != null
          ? BarcodeFormat.values.asNameMap()[json['format']]
          : null,
      type: parsedType,
      raw: json['raw'],
    );
  }

  /// Creates a [ScannedModel] directly from a freshly scanned [Barcode] or [BarcodeCapture]
  factory ScannedModel.fromBarcode(
    Barcode barcode, {
    String? id,
    bool? favorite,
    String? datetime,
  }) {
    final payload = barcode.rawValue ?? barcode.displayValue ?? '';
    final resolvedType = resolveBarcodeType(payload, barcode.type);

    return ScannedModel(
      id: id,
      name: barcode.displayValue ?? payload,
      datetime: datetime ?? DateTime.now().toIso8601String(),
      favorite: favorite ?? false,
      rawValue: payload,
      format: barcode.format,
      type: resolvedType,
      raw: [barcode.rawValue],
    );
  }

  /// Serializes the instance into a JSON map for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'datetime': datetime,
      'favorite': favorite,
      'rawValue': rawValue,
      'format': format?.name,
      'type': type?.name,
      'raw': raw,
    };
  }

  /// Returns a copy of this model with the given fields replaced by new values
  ScannedModel copyWith({
    String? id,
    String? name,
    String? datetime,
    bool? favorite,
    String? rawValue,
    BarcodeFormat? format,
    BarcodeType? type,
    dynamic raw,
  }) {
    final nextRawValue = rawValue ?? this.rawValue;
    var nextType = type ?? this.type;

    // Keep type aligned if rawValue was updated but no new type was provided
    if (type == null &&
        nextRawValue != null &&
        nextRawValue.trim().isNotEmpty) {
      nextType = resolveBarcodeType(nextRawValue, nextType);
    }

    return ScannedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      favorite: favorite ?? this.favorite,
      rawValue: nextRawValue,
      format: format ?? this.format,
      type: nextType,
      raw: raw ?? this.raw,
    );
  }

  /// Inspects raw payload contents to accurately classify [BarcodeType]
  static BarcodeType resolveBarcodeType(
    String payload, [
    BarcodeType? existingType,
  ]) {
    final clean = payload.trim();
    final lower = clean.toLowerCase();

    // 1. Wi-Fi
    if (lower.startsWith('wifi:') || lower.startsWith('wpa:')) {
      return BarcodeType.wifi;
    }

    // 2. UPI / Deep Link Payment Handlers
    if (lower.startsWith('upi://') || lower.startsWith('upi:')) {
      return BarcodeType.url;
    }

    // 3. Web URLs
    if (lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.') ||
        RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$').hasMatch(clean)) {
      return BarcodeType.url;
    }

    // 4. Contact Cards (vCard / MeCard / BizCard)
    if (lower.startsWith('begin:vcard') ||
        lower.startsWith('mecard:') ||
        lower.startsWith('bizcard:')) {
      return BarcodeType.contactInfo;
    }

    // 5. Telephone
    if (lower.startsWith('tel:') ||
        (existingType == BarcodeType.phone &&
            RegExp(r'^\+?[0-9\s\-()]{7,20}$').hasMatch(clean))) {
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

    // Retain detected non-generic type from ML Kit if valid
    if (existingType != null &&
        existingType != BarcodeType.text &&
        existingType != BarcodeType.unknown) {
      return existingType;
    }

    return BarcodeType.text;
  }
}
