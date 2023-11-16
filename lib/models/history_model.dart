class ScannedModel {
  String? id;
  String? name;
  String? datetime;
  bool? favorite;
  dynamic raw;

  ScannedModel({this.id, this.name, this.datetime, this.favorite, this.raw});

  ScannedModel.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    name = json['name'];
    datetime = json['datetime'];
    favorite = json['favorite'];
    raw = json['raw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['datetime'] = datetime;
    data['favorite'] = favorite;
    data['raw'] = raw;
    return data;
  }
}
