// history_state.dart
part of 'history_bloc.dart';

class HistoryState {
  const HistoryState._({required this.datas});

  final List<dynamic> datas;

  List<dynamic> get favoriteData =>
      datas.where((element) => element['favorite'] == true).toList();

  factory HistoryState.initial() {
    final Box<dynamic> box = Hive.box('history');
    final Box<dynamic> settingsBox = Hive.box('settings');
    final int deleteDays =
        settingsBox.get('deleteHistory', defaultValue: 0) as int;

    // Prune on initial load, strictly skipping favorites
    if (deleteDays != 0) {
      final now = DateTime.now();
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final element = box.get(key);
        if (element is Map) {
          // Do not delete favorite items
          if (element['favorite'] == true) continue;

          final dateStr = element['datetime']?.toString();
          if (dateStr != null) {
            final createdDate = DateTime.tryParse(dateStr);
            if (createdDate != null) {
              final daysFromCreated = now.difference(createdDate).inDays;
              if (daysFromCreated >= deleteDays) {
                keysToDelete.add(key);
              }
            }
          }
        }
      }

      for (final key in keysToDelete) {
        box.delete(key);
      }
    }

    return HistoryState._(datas: box.values.toList().reversed.toList());
  }

  HistoryState copyWith(List<dynamic>? datas) {
    return HistoryState._(datas: datas?.reversed.toList() ?? this.datas);
  }

  dynamic getOneData(String id) {
    final list = datas.where((element) => element['id'] == id).toList();
    return list.isNotEmpty ? list.first : null;
  }

  dynamic getRecentData() {
    return datas.isNotEmpty ? datas.first : null;
  }
}
