import 'package:mobile_scanner/mobile_scanner.dart';

/// data model representing a scanned barcode or qr record stored in persistent storage
class ScannedModel {
  /// unique identifier for the scan entry, typically a timestamp or uuid
  final String? id;

  /// human-readable display name or title for the record
  final String? name;

  /// iso-8601 formatted timestamp string representing when the scan occurred
  final String? datetime;

  /// indicates whether the user marked this scan entry as a favorite
  final bool? favorite;

  /// decoded raw string payload of the barcode (e.g. url, text, wifi string)
  final String? rawValue;

  /// detected symbology (e.g., qrCode, ean13, code128)
  final BarcodeFormat? format;

  /// semantic content type (e.g., url, wifi, contactInfo, sms)
  final BarcodeType? type;

  /// underlying raw payload preserved for backwards compatibility with legacy records
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

  /// creates a [ScannedModel] from persistent storage or json map
  factory ScannedModel.fromJson(Map<dynamic, dynamic> json) {
    return ScannedModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      datetime: json['datetime'] as String?,
      favorite: json['favorite'] as bool?,
      rawValue: json['rawValue'] as String?,
      format: json['format'] != null
          ? BarcodeFormat.values.asNameMap()[json['format']]
          : null,
      type: json['type'] != null
          ? BarcodeType.values.asNameMap()[json['type']]
          : null,
      raw: json['raw'],
    );
  }

  /// serializes the instance into a json map for local storage
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

  /// returns a copy of this model with the given fields replaced by new values
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
    return ScannedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      favorite: favorite ?? this.favorite,
      rawValue: rawValue ?? this.rawValue,
      format: format ?? this.format,
      type: type ?? this.type,
      raw: raw ?? this.raw,
    );
  }
}
