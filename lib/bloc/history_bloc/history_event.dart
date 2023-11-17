part of 'history_bloc.dart';

abstract class HistoryEvent {}

final class OnAddHistoryClicked extends HistoryEvent {
  BarcodeCapture barcode;
  OnAddHistoryClicked(this.barcode);
}

final class OnDeleteHistoryClicked extends HistoryEvent {
  String id;
  OnDeleteHistoryClicked(this.id);
}

final class OnDeleteAllHistoryClicked extends HistoryEvent {}

final class OnFavoriteToggleClicked extends HistoryEvent {
  String id;
  OnFavoriteToggleClicked(this.id);
}

final class OnUnfavoriteAllClicked extends HistoryEvent {}
