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
