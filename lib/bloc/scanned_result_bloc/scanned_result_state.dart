part of 'scanned_result_bloc.dart';

class ScannedResultState {
  ScannedResultState._(
      {required this.screenshotController, required this.scannedModel});

  final ScreenshotController? screenshotController;
  final ScannedModel scannedModel;

  factory ScannedResultState.initial(ScannedModel scannedModel) {
    ScreenshotController controller = ScreenshotController();
    return ScannedResultState._(
        screenshotController: controller, scannedModel: scannedModel);
  }

  ScannedResultState copyWith({ScannedModel? scannedModel}) {
    return ScannedResultState._(
        screenshotController: screenshotController,
        scannedModel: scannedModel ?? this.scannedModel);
  }
}
