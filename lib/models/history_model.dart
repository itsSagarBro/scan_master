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

  /// underlying raw payload returned by the scanner platform channel
  final dynamic raw;

  const ScannedModel({
    this.id,
    this.name,
    this.datetime,
    this.favorite,
    this.raw,
  });

  /// creates a [ScannedModel] from a persistent storage or json map
  factory ScannedModel.fromJson(Map<dynamic, dynamic> json) {
    return ScannedModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      datetime: json['datetime'] as String?,
      favorite: json['favorite'] as bool?,
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
      'raw': raw,
    };
  }

  /// returns a copy of this model with the given fields replaced by new values
  ScannedModel copyWith({
    String? id,
    String? name,
    String? datetime,
    bool? favorite,
    dynamic raw,
  }) {
    return ScannedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      favorite: favorite ?? this.favorite,
      raw: raw ?? this.raw,
    );
  }
}
