import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    Box settingsBox = Hive.box("settings");

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

    on<ToggleSaveHistory>((event, emit) async {
      await settingsBox.put("saveHistory", event.value);
      emit(state.copyWith(saveHistory: event.value));
    });
  }

  bool get saveHistory => state.saveHistory;
}
