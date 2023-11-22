part of 'settings_bloc.dart';

abstract class SettingsEvent {}

final class OnThemeChanged extends SettingsEvent {
  int value;
  OnThemeChanged(this.value);
}

final class ToggleSaveHistory extends SettingsEvent {
  bool value;
  ToggleSaveHistory(this.value);
}

final class OnHistoryDeleteTimeChanged extends SettingsEvent {
  int value;
  OnHistoryDeleteTimeChanged(this.value);
}

final class ToggleAutoCopy extends SettingsEvent {
  bool value;
  ToggleAutoCopy(this.value);
}

final class ToggleAutoOpenUrl extends SettingsEvent {
  bool value;
  ToggleAutoOpenUrl(this.value);
}

final class ToggleAutoDownloadQr extends SettingsEvent {
  bool value;
  ToggleAutoDownloadQr(this.value);
}

final class ToggleQrImageShare extends SettingsEvent {
  bool value;
  ToggleQrImageShare(this.value);
}
