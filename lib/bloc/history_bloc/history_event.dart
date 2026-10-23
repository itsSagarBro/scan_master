part of 'history_bloc.dart';

sealed class HistoryEvent {
  const HistoryEvent();
}

final class OnAddHistoryClicked extends HistoryEvent {
  final BarcodeCapture barcode;
  const OnAddHistoryClicked(this.barcode);
}

final class OnDeleteHistoryClicked extends HistoryEvent {
  final String id;
  const OnDeleteHistoryClicked(this.id);
}

final class OnDeleteAllHistoryClicked extends HistoryEvent {
  const OnDeleteAllHistoryClicked();
}

final class OnFavoriteToggleClicked extends HistoryEvent {
  final String id;
  final ScannedModel? model;

  const OnFavoriteToggleClicked(this.id, {this.model});
}

final class OnUnfavoriteAllClicked extends HistoryEvent {
  const OnUnfavoriteAllClicked();
}
