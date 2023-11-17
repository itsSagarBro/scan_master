import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/models/history_model.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    Box box = Hive.box("history");

    on<OnAddHistoryClicked>((event, emit) async {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      ScannedModel scannedModel = ScannedModel(
          id: id,
          name: event.barcode.barcodes[0].displayValue,
          datetime: DateTime.now().toString(),
          favorite: false,
          raw: event.barcode.raw);
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

    on<OnFavoriteToggleClicked>((event, emit) async {
      if (box.containsKey(event.id)) {
        ScannedModel scannedModel = ScannedModel.fromJson(box.get(event.id));
        scannedModel.favorite = !scannedModel.favorite!;
        await box.put(event.id, scannedModel.toJson());
        emit(state.copyWith(box.values.toList()));
      }
    });

    on<OnUnfavoriteAllClicked>((event, emit) async {
      for (var data in state.favoriteData) {
        if (box.containsKey(data.id)) {
          ScannedModel scannedModel = ScannedModel.fromJson(data);
          scannedModel.favorite = false;
          await box.put(scannedModel.id, scannedModel.toJson());
        }
      }

      emit(state.copyWith(box.values.toList()));
    });
  }
}
