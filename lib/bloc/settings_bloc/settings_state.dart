part of 'settings_bloc.dart';

class SettingsState {
  SettingsState._(
      {required this.themeMode,
      required this.saveHistory,
      required this.deleteHistory,
      required this.autoCopy,
      required this.autoOpenUrl,
      required this.qrAutoDownload,
      required this.qrImageShare});

  final ThemeMode themeMode;
  final bool saveHistory;
  final int deleteHistory;
  final bool autoCopy;
  final bool autoOpenUrl;
  final bool qrAutoDownload;
  final bool qrImageShare;

  factory SettingsState.initial() {
    Box settingsBox = Hive.box("settings");
    ThemeMode themeMode;

    switch (settingsBox.get("themeMode", defaultValue: 0)) {
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

    return SettingsState._(
        themeMode: themeMode,
        saveHistory: settingsBox.get("saveHistory", defaultValue: true),
        deleteHistory: settingsBox.get("deleteHistory", defaultValue: 0),
        autoCopy: settingsBox.get("autoCopy", defaultValue: false),
        autoOpenUrl: settingsBox.get("autoOpenUrl", defaultValue: false),
        qrAutoDownload: settingsBox.get("qrAutoDownload", defaultValue: false),
        qrImageShare: settingsBox.get("qrImageShare", defaultValue: false));
  }

  SettingsState copyWith(
      {ThemeMode? themeMode,
      bool? saveHistory,
      int? deleteHistory,
      bool? autoCopy,
      bool? autoOpenUrl,
      bool? qrAutoDownload,
      bool? qrImageShare}) {
    return SettingsState._(
        themeMode: themeMode ?? this.themeMode,
        saveHistory: saveHistory ?? this.saveHistory,
        deleteHistory: deleteHistory ?? this.deleteHistory,
        autoCopy: autoCopy ?? this.autoCopy,
        autoOpenUrl: autoOpenUrl ?? this.autoOpenUrl,
        qrAutoDownload: qrAutoDownload ?? this.qrAutoDownload,
        qrImageShare: qrImageShare ?? this.qrImageShare);
  }

  int getThemeSwitch() {
    switch (themeMode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }
}
