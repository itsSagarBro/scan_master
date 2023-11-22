import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    Box settingsBox = Hive.box("settings");

    /// This called when user changes app theme according to them
    on<OnThemeChanged>((event, emit) async {
      ThemeMode themeMode;
      switch (event.value) {
        case 1:
          themeMode = ThemeMode.light;
          break;
        case 2:
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
          break;
      }

      await settingsBox.put("themeMode", event.value);
      emit(state.copyWith(themeMode: themeMode));
    });

    /// This called when user toggle the save history switch
    on<ToggleSaveHistory>((event, emit) async {
      await settingsBox.put("saveHistory", event.value);
      emit(state.copyWith(saveHistory: event.value));
    });

    /// This called when user changes delete time of history
    on<OnHistoryDeleteTimeChanged>((event, emit) async {
      await settingsBox.put("deleteHistory", event.value);
      emit(state.copyWith(deleteHistory: event.value));
    });

    /// This called when user toggle the auto copy switch
    on<ToggleAutoCopy>((event, emit) async {
      await settingsBox.put("autoCopy", event.value);

      // This is for resctricting the user to toggle on both auto open url and auto copy at same time
      bool autoOpenUrl = state.autoOpenUrl;

      if (autoOpenUrl && event.value) {
        autoOpenUrl = false;
        await settingsBox.put("autoOpenUrl", false);
      }

      emit(state.copyWith(autoCopy: event.value, autoOpenUrl: autoOpenUrl));
    });

    /// This called when user toggle the auto open url switch
    on<ToggleAutoOpenUrl>((event, emit) async {
      await settingsBox.put("autoOpenUrl", event.value);

      // This is for resctricting the user to toggle on both auto open url and auto copy at same time
      bool autoCopy = state.autoCopy;

      if (autoCopy && event.value) {
        autoCopy = false;
        await settingsBox.put("autoCopy", false);
      }

      emit(state.copyWith(autoOpenUrl: event.value, autoCopy: autoCopy));
    });

    /// This called when user toggle the auto download qr code switch
    on<ToggleAutoDownloadQr>((event, emit) async {
      await settingsBox.put("qrAutoDownload", event.value);
      emit(state.copyWith(qrAutoDownload: event.value));
    });

    /// This called when user toggle the qr image share when user sharing the response
    on<ToggleQrImageShare>((event, emit) async {
      await settingsBox.put("qrImageShare", event.value);
      emit(state.copyWith(qrImageShare: event.value));
    });
  }

  // This is get's for use of whiout builded
  bool get saveHistory => state.saveHistory;
  bool get shareQrImage => state.qrImageShare;
  bool get autoCopy => state.autoCopy;
  bool get autoOpenUrl => state.autoOpenUrl;
  bool get qrAutoDownload => state.qrAutoDownload;
}
