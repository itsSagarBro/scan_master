import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Settings",
          style: appBarHeading(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Column(
              children: [
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "Theme Mode",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      DropdownButton(
                        value: state.getThemeSwitch(),
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(15),
                        alignment: AlignmentDirectional.centerEnd,
                        items: [
                          DropdownMenuItem(
                              value: 0,
                              child: Text(
                                "System",
                                style: defaultTextStyle(),
                              )),
                          DropdownMenuItem(
                              value: 1,
                              child: Text(
                                "Light",
                                style: defaultTextStyle(),
                              )),
                          DropdownMenuItem(
                              value: 2,
                              child: Text(
                                "Dark",
                                style: defaultTextStyle(),
                              ))
                        ],
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(OnThemeChanged(value ?? 0)),
                      )
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "Save History",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.saveHistory,
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(ToggleSaveHistory(value)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "Delete history after",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      DropdownButton(
                        value: state.deleteHistory,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(15),
                        alignment: AlignmentDirectional.centerEnd,
                        items: [
                          DropdownMenuItem(
                              value: 0,
                              child: Text(
                                "Never",
                                style: defaultTextStyle(),
                              )),
                          DropdownMenuItem(
                              value: 7,
                              child: Text(
                                "7 Days",
                                style: defaultTextStyle(),
                              )),
                          DropdownMenuItem(
                              value: 30,
                              child: Text(
                                "30 Days",
                                style: defaultTextStyle(),
                              ))
                        ],
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(OnHistoryDeleteTimeChanged(value ?? 0)),
                      )
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "Automatic Copy",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.autoCopy,
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(ToggleAutoCopy(value)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "Automatic open URLs",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.autoOpenUrl,
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(ToggleAutoOpenUrl(value)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "QR Auto download",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.qrAutoDownload,
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(ToggleAutoDownloadQr(value)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: Row(
                    children: [
                      Text(
                        "QR Image share",
                        style: defaultTextStyle(),
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: state.qrImageShare,
                        onChanged: (value) =>
                            BlocProvider.of<SettingsBloc>(context)
                                .add(ToggleQrImageShare(value)),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
