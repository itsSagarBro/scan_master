part of 'history_bloc.dart';

/// base class for all events handled by [HistoryBloc]
sealed class HistoryEvent {
  const HistoryEvent();
}

/// triggered when a new barcode or qr code is detected and needs to be persisted
final class OnAddHistoryClicked extends HistoryEvent {
  final BarcodeCapture barcode;

  const OnAddHistoryClicked(this.barcode);
}

/// triggered to remove a single history item by its unique [id]
final class OnDeleteHistoryClicked extends HistoryEvent {
  final String id;

  const OnDeleteHistoryClicked(this.id);
}

/// triggered to wipe the entire history box from local storage
final class OnDeleteAllHistoryClicked extends HistoryEvent {
  const OnDeleteAllHistoryClicked();
}

/// triggered to toggle the favorite or starred status of an entry by its [id]
final class OnFavoriteToggleClicked extends HistoryEvent {
  final String id;

  const OnFavoriteToggleClicked(this.id);
}

/// triggered to clear the favorite status from all currently starred records
final class OnUnfavoriteAllClicked extends HistoryEvent {
  const OnUnfavoriteAllClicked();
}
