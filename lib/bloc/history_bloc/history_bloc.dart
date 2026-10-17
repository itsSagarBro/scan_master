import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/models/history_model.dart';

part 'history_event.dart';
part 'history_state.dart';

/// manages persistent scan history operations including adding, deleting,
/// toggling favorites, and bulk unmark actions via hive local storage.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    final Box<dynamic> box = Hive.box('history');

    // add a newly scanned item to the history box
    on<OnAddHistoryClicked>((event, emit) async {
      if (event.barcode.barcodes.isEmpty) return;

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final scannedModel = ScannedModel(
        id: id,
        name: event.barcode.barcodes.first.displayValue,
        datetime: DateTime.now().toIso8601String(),
        favorite: false,
        raw: event.barcode.raw,
      );

      await box.put(id, scannedModel.toJson());
      emit(state.copyWith(box.values.toList()));
    });

    // remove an item from history by its unique identifier
    on<OnDeleteHistoryClicked>((event, emit) async {
      if (box.containsKey(event.id)) {
        await box.delete(event.id);
        emit(state.copyWith(box.values.toList()));
      }
    });

    // delete all history records from persistent storage
    on<OnDeleteAllHistoryClicked>((event, emit) async {
      await box.clear();
      emit(state.copyWith(box.values.toList()));
    });

    // toggle the favorite bookmark status of a specific scan record
    on<OnFavoriteToggleClicked>((event, emit) async {
      if (box.containsKey(event.id)) {
        final existingRaw = box.get(event.id);
        final scannedModel = ScannedModel.fromJson(existingRaw as Map);
        final updatedModel = scannedModel.copyWith(
          favorite: !(scannedModel.favorite ?? false),
        );

        await box.put(event.id, updatedModel.toJson());
        emit(state.copyWith(box.values.toList()));
      }
    });

    // clear the favorite status across all currently bookmarked scans
    on<OnUnfavoriteAllClicked>((event, emit) async {
      for (final item in state.favoriteData) {
        final scannedModel = ScannedModel.fromJson(item as Map);
        if (scannedModel.id != null && box.containsKey(scannedModel.id)) {
          final updatedModel = scannedModel.copyWith(favorite: false);
          await box.put(scannedModel.id, updatedModel.toJson());
        }
      }

      emit(state.copyWith(box.values.toList()));
    });
  }
}
