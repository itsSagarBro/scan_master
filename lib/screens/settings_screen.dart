import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/text_styles.dart';

/// provides user configuration options for theme preferences,
/// scan history retention policies, and automated scan actions.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Settings',
          style: appBarHeading(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            final settingsBloc = context.read<SettingsBloc>();

            return Column(
              children: [
                // theme selection: system default, light, or dark
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'Theme Mode',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: state.getThemeSwitch(),
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(15),
                        alignment: AlignmentDirectional.centerEnd,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'System',
                              style: defaultTextStyle(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Light',
                              style: defaultTextStyle(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Dark',
                              style: defaultTextStyle(),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsBloc.add(OnThemeChanged(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // toggle persistent storage of scanned records
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'Save History',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.saveHistory,
                        onChanged: (value) =>
                            settingsBloc.add(ToggleSaveHistory(value)),
                      ),
                    ],
                  ),
                ),
                // history retention duration policy
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'Delete history after',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: state.deleteHistory,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(15),
                        alignment: AlignmentDirectional.centerEnd,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Never',
                              style: defaultTextStyle(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 7,
                            child: Text(
                              '7 Days',
                              style: defaultTextStyle(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text(
                              '30 Days',
                              style: defaultTextStyle(),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsBloc.add(OnHistoryDeleteTimeChanged(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // automated clipboard copy upon scanning
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'Automatic Copy',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.autoCopy,
                        onChanged: (value) =>
                            settingsBloc.add(ToggleAutoCopy(value)),
                      ),
                    ],
                  ),
                ),
                // automated browser navigation for url barcodes
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'Automatic open URLs',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.autoOpenUrl,
                        onChanged: (value) =>
                            settingsBloc.add(ToggleAutoOpenUrl(value)),
                      ),
                    ],
                  ),
                ),
                // automated saving of rendered barcode image to disk
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'QR Auto download',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.qrAutoDownload,
                        onChanged: (value) =>
                            settingsBloc.add(ToggleAutoDownloadQr(value)),
                      ),
                    ],
                  ),
                ),
                // include rendered barcode image when sharing scan payload
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        'QR Image share',
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.qrImageShare,
                        onChanged: (value) =>
                            settingsBloc.add(ToggleQrImageShare(value)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
