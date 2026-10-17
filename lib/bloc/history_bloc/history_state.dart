part of 'history_bloc.dart';

/// represents the current state of stored scan records, including history retention checks
class HistoryState {
  const HistoryState._({required this.datas});

  /// list of stored scan records arranged in reverse chronological order
  final List<dynamic> datas;

  /// returns only items marked as favorite
  List<dynamic> get favoriteData =>
      datas.where((element) => element['favorite'] == true).toList();

  /// initializes history state and applies automated data retention policies
  factory HistoryState.initial() {
    final Box<dynamic> box = Hive.box('history');
    final Box<dynamic> settingsBox = Hive.box('settings');
    final int deleteDays =
        settingsBox.get('deleteHistory', defaultValue: 0) as int;

    // prune records older than the user configured retention limit
    if (deleteDays != 0) {
      final now = DateTime.now();
      for (final element in box.values) {
        if (element is Map && element['datetime'] != null) {
          final createdDate = DateTime.tryParse(element['datetime'].toString());
          if (createdDate != null) {
            final daysFromCreated = now.difference(createdDate).inDays;
            if (daysFromCreated > deleteDays) {
              box.delete(element['id']);
            }
          }
        }
      }
    }

    return HistoryState._(datas: box.values.toList().reversed.toList());
  }

  /// returns a new [HistoryState] instance with updated scan data reversed
  HistoryState copyWith(List<dynamic>? datas) {
    return HistoryState._(datas: datas?.reversed.toList() ?? this.datas);
  }

  /// finds a single scan entry by its unique identifier
  dynamic getOneData(String id) {
    final list = datas.where((element) => element['id'] == id).toList();
    return list.isNotEmpty ? list.first : null;
  }

  /// returns the most recently scanned item, or null if history is empty
  dynamic getRecentData() {
    return datas.isNotEmpty ? datas.first : null;
  }
}
