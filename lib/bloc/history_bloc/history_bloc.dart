import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scan_master/models/history_model.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    Box box = Hive.box("history");

    on<OnDeleteHistoryClicked>((event, emit) {
      box.delete(event.id);
      emit(state.copyWith(box.values.toList()));
    });

    on<OnDeleteAllHistoryClicked>((event, emit) {
      box.clear();
      emit(state.copyWith(box.values.toList()));
    });

    on<OnFavoriteToggleClicked>((event, emit) {
      ScannedModel scannedModel = ScannedModel.fromJson(box.get(event.id));
      scannedModel.favorite = !scannedModel.favorite!;
      box.put(event.id, scannedModel.toJson());
      emit(state.copyWith(box.values.toList()));
    });

    on<OnUnfavoriteAllClicked>((event, emit) {
      for (var data in state.favoriteData) {
        ScannedModel scannedModel = ScannedModel.fromJson(data);
        scannedModel.favorite = false;
        box.put(scannedModel.id, scannedModel.toJson());
      }

      emit(state.copyWith(box.values.toList()));
    });
  }
}
