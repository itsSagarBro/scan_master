import 'package:bloc/bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryState.initial()) {
    on<DeleteHistory>((event, emit) {
      Box box = Hive.box("history");
      box.deleteAt(event.index);
      emit(state.copyWith(box.values.toList()));
    });
  }
}
