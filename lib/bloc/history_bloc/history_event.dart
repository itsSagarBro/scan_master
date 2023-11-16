part of 'history_bloc.dart';

abstract class HistoryEvent {}

final class DeleteHistory extends HistoryEvent {
  int index;

  DeleteHistory(this.index);
}
