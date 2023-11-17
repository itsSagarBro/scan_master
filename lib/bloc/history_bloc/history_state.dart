part of 'history_bloc.dart';

class HistoryState {
  HistoryState._({required this.datas});

  Box box = Hive.box("history");
  final List<dynamic> datas;

  List<dynamic> get favoriteData =>
      datas.where((element) => element["favorite"] == true).toList();

  factory HistoryState.initial() {
    Box box = Hive.box("history");
    return HistoryState._(datas: box.values.toList().reversed.toList());
  }

  HistoryState copyWith(List<dynamic>? datas) {
    return HistoryState._(datas: datas?.reversed.toList() ?? this.datas);
  }
}
