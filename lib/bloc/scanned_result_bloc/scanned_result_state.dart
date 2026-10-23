part of 'scanned_result_bloc.dart';

enum ActionStatus { idle, success, failure }

class ScannedResultState {
  final ScreenshotController? screenshotController;
  final ScannedModel scannedModel;
  final ActionStatus actionStatus;
  final String? message;

  const ScannedResultState._({
    required this.screenshotController,
    required this.scannedModel,
    this.actionStatus = ActionStatus.idle,
    this.message,
  });

  factory ScannedResultState.initial(ScannedModel scannedModel) {
    return ScannedResultState._(
      screenshotController: ScreenshotController(),
      scannedModel: scannedModel,
    );
  }

  ScannedResultState copyWith({
    ScannedModel? scannedModel,
    ScreenshotController? screenshotController,
    ActionStatus? actionStatus,
    String? message,
  }) {
    return ScannedResultState._(
      screenshotController: screenshotController ?? this.screenshotController,
      scannedModel: scannedModel ?? this.scannedModel,
      actionStatus: actionStatus ?? ActionStatus.idle,
      message: message,
    );
  }
}
