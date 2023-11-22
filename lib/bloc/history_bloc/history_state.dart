part of 'history_bloc.dart';

class HistoryState {
  HistoryState._({required this.datas});

  Box box = Hive.box("history");
  final List<dynamic> datas;

  List<dynamic> get favoriteData =>
      datas.where((element) => element["favorite"] == true).toList();

  factory HistoryState.initial() {
    Box box = Hive.box("history");
    int deleteDays = Hive.box("settings").get("deleteHistory", defaultValue: 0);
    if (deleteDays != 0) {
      for (var element in box.values) {
        DateTime createdDate = DateTime.parse(element["datetime"]);
        int daysFromCreated = DateTime.now().difference(createdDate).inDays;
        log(daysFromCreated.toString());
        if (daysFromCreated > deleteDays) {
          box.delete(element["id"]);
        }
      }
    }
    return HistoryState._(datas: box.values.toList().reversed.toList());
  }

  HistoryState copyWith(List<dynamic>? datas) {
    return HistoryState._(datas: datas?.reversed.toList() ?? this.datas);
  }

  dynamic getOneData(String id) {
    List list = datas.where((element) => element["id"] == id).toList();
    return list.isNotEmpty ? list.first : null;
  }

  dynamic getRecentData() {
    return datas.last;
  }
}
