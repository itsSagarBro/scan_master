part of 'scanned_result_bloc.dart';

class ScannedResultState {
  ScannedResultState._({required this.screenshotController});

  final ScreenshotController? screenshotController;

  factory ScannedResultState.initial() {
    ScreenshotController controller = ScreenshotController();
    return ScannedResultState._(screenshotController: controller);
  }

  ScannedResultState copyWith() {
    return ScannedResultState._(screenshotController: screenshotController);
  }
}
