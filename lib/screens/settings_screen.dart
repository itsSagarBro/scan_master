import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/utils/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = info.version;
      });
    } catch (_) {
      // Fallback to default if platform query fails
    }
  }

  void _showThemePicker(
    BuildContext context,
    int currentTheme,
    SettingsBloc bloc,
    ThemeData theme,
  ) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose Theme',
                style:
                    defaultTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildPickerOption(
                context: sheetContext,
                title: 'System Default',
                subtitle: 'Follow device appearance preferences',
                icon: Icons.brightness_auto_rounded,
                isSelected: currentTheme == 0,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnThemeChanged(0));
                },
              ),
              _buildPickerOption(
                context: sheetContext,
                title: 'Light Theme',
                subtitle: 'Crisp, high-contrast daylight mode',
                icon: Icons.light_mode_rounded,
                isSelected: currentTheme == 1,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnThemeChanged(1));
                },
              ),
              _buildPickerOption(
                context: sheetContext,
                title: 'Dark Theme',
                subtitle: 'OLED-friendly dark palette',
                icon: Icons.dark_mode_rounded,
                isSelected: currentTheme == 2,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnThemeChanged(2));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRetentionPicker(
    BuildContext context,
    int currentDays,
    SettingsBloc bloc,
    ThemeData theme,
  ) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'History Retention Policy',
                style:
                    defaultTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _buildPickerOption(
                context: sheetContext,
                title: 'Never delete',
                subtitle:
                    'Keep scan history permanently until manually cleared',
                icon: Icons.all_inclusive_rounded,
                isSelected: currentDays == 0,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnHistoryDeleteTimeChanged(0));
                },
              ),
              _buildPickerOption(
                context: sheetContext,
                title: 'After 7 Days',
                subtitle: 'Automatically delete scans older than one week',
                icon: Icons.calendar_view_week_rounded,
                isSelected: currentDays == 7,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnHistoryDeleteTimeChanged(7));
                },
              ),
              _buildPickerOption(
                context: sheetContext,
                title: 'After 30 Days',
                subtitle: 'Prune scans older than a month',
                icon: Icons.calendar_month_rounded,
                isSelected: currentDays == 30,
                onTap: () {
                  Navigator.pop(sheetContext);
                  HapticFeedback.selectionClick();
                  bloc.add(OnHistoryDeleteTimeChanged(30));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPickerOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: defaultTextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: defaultTextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded,
                color: theme.colorScheme.primary, size: 22)
            : null,
        onTap: onTap,
      ),
    );
  }

  String _getThemeLabel(int code) {
    return switch (code) {
      1 => 'Light',
      2 => 'Dark',
      _ => 'System',
    };
  }

  String _getRetentionLabel(int days) {
    if (days == 0) return 'Never';
    return '$days Days';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              shape: const CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 17),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: defaultTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final settingsBloc = context.read<SettingsBloc>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              // 1. Appearance Section
              _buildSectionHeader('APPEARANCE', theme),
              _buildCardContainer(
                theme,
                children: [
                  _buildNavigationRow(
                    theme: theme,
                    icon: Icons.palette_outlined,
                    title: 'Theme Mode',
                    subtitle: 'Choose dark, light, or follow system theme',
                    valueDisplay: _getThemeLabel(state.getThemeSwitch()),
                    onTap: () => _showThemePicker(
                      context,
                      state.getThemeSwitch(),
                      settingsBloc,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Storage & History Section
              _buildSectionHeader('SCAN STORAGE & HISTORY', theme),
              _buildCardContainer(
                theme,
                children: [
                  _buildSwitchRow(
                    theme: theme,
                    icon: Icons.history_rounded,
                    title: 'Save History',
                    subtitle: 'Persist all scanned barcodes to local database',
                    value: state.saveHistory,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      settingsBloc.add(ToggleSaveHistory(value));
                    },
                  ),
                  if (state.saveHistory) ...[
                    _buildDivider(theme),
                    _buildNavigationRow(
                      theme: theme,
                      icon: Icons.auto_delete_outlined,
                      title: 'Delete History After',
                      subtitle: 'Auto-prune old scan entries',
                      valueDisplay: _getRetentionLabel(state.deleteHistory),
                      onTap: () => _showRetentionPicker(
                        context,
                        state.deleteHistory,
                        settingsBloc,
                        theme,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // 3. Automated Actions Section
              _buildSectionHeader('AUTOMATION WORKFLOWS', theme),
              _buildCardContainer(
                theme,
                children: [
                  _buildSwitchRow(
                    theme: theme,
                    icon: Icons.copy_all_rounded,
                    title: 'Auto Copy Payload',
                    subtitle: 'Copy scanned text to clipboard immediately',
                    value: state.autoCopy,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      settingsBloc.add(ToggleAutoCopy(value));
                    },
                  ),
                  _buildDivider(theme),
                  _buildSwitchRow(
                    theme: theme,
                    icon: Icons.open_in_browser_rounded,
                    title: 'Auto Open URLs',
                    subtitle:
                        'Launch detected website links directly upon scanning',
                    value: state.autoOpenUrl,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      settingsBloc.add(ToggleAutoOpenUrl(value));
                    },
                  ),
                  _buildDivider(theme),
                  _buildSwitchRow(
                    theme: theme,
                    icon: Icons.downloading_rounded,
                    title: 'Auto Save Image',
                    subtitle:
                        'Save generated or scanned code picture to gallery',
                    value: state.qrAutoDownload,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      settingsBloc.add(ToggleAutoDownloadQr(value));
                    },
                  ),
                  _buildDivider(theme),
                  _buildSwitchRow(
                    theme: theme,
                    icon: Icons.image_outlined,
                    title: 'Include QR Image on Share',
                    subtitle:
                        'Attach the code rendering alongside the text when sharing',
                    value: state.qrImageShare,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      settingsBloc.add(ToggleQrImageShare(value));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. About & Application Information Section
              _buildSectionHeader('APPLICATION', theme),
              _buildCardContainer(
                theme,
                children: [
                  _buildNavigationRow(
                    theme: theme,
                    icon: Icons.info_outline_rounded,
                    title: 'About Scan Master',
                    subtitle: 'Version details, developer info, and licenses',
                    valueDisplay: 'v$_version',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/about');
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        title,
        style: defaultTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme,
      {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon,
                size: 21, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: defaultTextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: defaultTextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required String valueDisplay,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon,
                    size: 21, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: defaultTextStyle(
                        fontSize: 11,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      valueDisplay,
                      style: defaultTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 14,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
    );
  }
}
