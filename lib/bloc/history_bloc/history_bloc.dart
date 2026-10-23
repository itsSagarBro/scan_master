import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/models/history_model.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    final Box<dynamic> box = Hive.box('history');

    on<OnAddHistoryClicked>((event, emit) async {
      if (event.barcode.barcodes.isEmpty) return;

      final first = event.barcode.barcodes.first;
      final payload = first.rawValue ?? first.displayValue ?? '';
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final scannedModel = ScannedModel(
        id: id,
        name: first.displayValue ?? payload,
        datetime: DateTime.now().toIso8601String(),
        favorite: false,
        rawValue: payload,
        format: first.format,
        type: first.type,
        raw: event.barcode.raw,
      );

      await box.put(id, scannedModel.toJson());
      emit(state.copyWith(box.values.toList()));
    });

    on<OnDeleteHistoryClicked>((event, emit) async {
      if (box.containsKey(event.id)) {
        await box.delete(event.id);
        emit(state.copyWith(box.values.toList()));
      }
    });

    on<OnDeleteAllHistoryClicked>((event, emit) async {
      await box.clear();
      emit(state.copyWith(box.values.toList()));
    });

    // Toggle favorite or auto-insert if record was not yet written to Hive
    on<OnFavoriteToggleClicked>((event, emit) async {
      final id = event.model?.id ?? event.id;
      if (id == null || id.isEmpty) return;

      if (box.containsKey(id)) {
        final existingRaw = box.get(id);
        final scannedModel = ScannedModel.fromJson(existingRaw as Map);
        final updatedModel = scannedModel.copyWith(
          favorite: !(scannedModel.favorite ?? false),
        );

        await box.put(id, updatedModel.toJson());
      } else if (event.model != null) {
        // Record was not in Hive yet (e.g., live scan with save history off)
        final newModel = event.model!.copyWith(
          id: id,
          favorite: !(event.model!.favorite ?? false),
          datetime: event.model!.datetime ?? DateTime.now().toIso8601String(),
        );
        await box.put(id, newModel.toJson());
      }

      emit(state.copyWith(box.values.toList()));
    });

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
