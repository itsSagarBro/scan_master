import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:share_plus/share_plus.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  IconData _getTypeIcon(BarcodeType? type) {
    return switch (type) {
      BarcodeType.url => Icons.link_rounded,
      BarcodeType.wifi => Icons.wifi_rounded,
      BarcodeType.phone => Icons.call_rounded,
      BarcodeType.sms => Icons.sms_outlined,
      BarcodeType.email => Icons.email_outlined,
      BarcodeType.contactInfo => Icons.badge_outlined,
      BarcodeType.geo => Icons.near_me_outlined,
      _ => Icons.qr_code_2_rounded,
    };
  }

  void _showItemOptions(
    BuildContext context,
    ScannedModel model,
    ThemeData theme,
  ) {
    HapticFeedback.selectionClick();
    final payload = model.rawValue ?? model.name ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),

              // Preview Header Tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getTypeIcon(model.type),
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.format?.name.toUpperCase() ?? 'CODE',
                            style: defaultTextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            payload,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: defaultTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              _buildBottomSheetAction(
                context: bottomSheetContext,
                icon: Icons.copy_rounded,
                title: 'Copy to Clipboard',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Clipboard.setData(ClipboardData(text: payload));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildBottomSheetAction(
                context: bottomSheetContext,
                icon: Icons.share_rounded,
                title: 'Share Payload',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Share.share(payload);
                },
              ),
              _buildBottomSheetAction(
                context: bottomSheetContext,
                icon: Icons.star_border_rounded,
                title: 'Remove from Favorites',
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (model.id != null) {
                    HapticFeedback.lightImpact();
                    context.read<HistoryBloc>().add(
                          OnFavoriteToggleClicked(model.id!, model: model),
                        );
                  }
                },
              ),
              _buildBottomSheetAction(
                context: bottomSheetContext,
                icon: Icons.delete_outline_rounded,
                title: 'Delete from Storage',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (model.id != null) {
                    HapticFeedback.mediumImpact();
                    context
                        .read<HistoryBloc>()
                        .add(OnDeleteHistoryClicked(model.id!));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          title,
          style: defaultTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showUnfavoriteAllConfirmDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Unfavorite All?',
          style: defaultTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will remove all items from your favorites, but keep them in your history.',
          style: defaultTextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: defaultTextStyle()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              HapticFeedback.mediumImpact();
              context.read<HistoryBloc>().add(const OnUnfavoriteAllClicked());
            },
            child: Text(
              'Unfavorite All',
              style: defaultTextStyle(color: theme.colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Today';
    if (itemDate == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
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
          'Favorites',
          style: defaultTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state.favoriteData.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  tooltip: 'Unfavorite all',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer
                          .withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_half_rounded,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onPressed: () =>
                      _showUnfavoriteAllConfirmDialog(context, theme),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          final favoriteModels = state.favoriteData
              .whereType<Map>()
              .map((map) => ScannedModel.fromJson(map))
              .toList();

          if (favoriteModels.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.star_outline_rounded,
                        size: 44,
                        color: Colors.amber.shade700.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'No favorites starred',
                      style: defaultTextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Star frequently used codes from the scanner or history to keep them organized here.',
                      textAlign: TextAlign.center,
                      style: defaultTextStyle(
                        fontSize: 13,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 13),
                        elevation: 0,
                      ),
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                      label: const Text('Start Scanning'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: favoriteModels.length,
            itemBuilder: (context, index) {
              final item = favoriteModels[index];
              final itemId = item.id;
              final payload = item.rawValue ?? item.name ?? 'No Content';

              DateTime itemDate = DateTime.now();
              if (item.datetime != null) {
                itemDate = DateTime.tryParse(item.datetime!) ?? DateTime.now();
              }

              bool showHeader = false;
              if (index == 0) {
                showHeader = true;
              } else {
                final prevDate = DateTime.tryParse(
                        favoriteModels[index - 1].datetime ?? '') ??
                    DateTime.now();
                if (_getDateHeader(itemDate) != _getDateHeader(prevDate)) {
                  showHeader = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
                      child: Row(
                        children: [
                          Text(
                            _getDateHeader(itemDate),
                            style: defaultTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            context.push('/favorites/scanned', extra: item),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                          child: Row(
                            children: [
                              // Squircle Icon Tile
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _getTypeIcon(item.type),
                                  size: 22,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Payload Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.75),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.format?.name.toUpperCase() ??
                                                'CODE',
                                            style: defaultTextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '• ${_formatTime(itemDate)}',
                                          style: defaultTextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.45),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      payload,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: defaultTextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Star Button (One-tap Unfavorite)
                              IconButton(
                                splashRadius: 18,
                                icon: Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber.shade600,
                                  size: 23,
                                ),
                                onPressed: () {
                                  if (itemId != null) {
                                    HapticFeedback.lightImpact();
                                    context.read<HistoryBloc>().add(
                                          OnFavoriteToggleClicked(itemId,
                                              model: item),
                                        );
                                  }
                                },
                              ),

                              // Context Menu Sheet Button
                              IconButton(
                                splashRadius: 18,
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 19,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                onPressed: () =>
                                    _showItemOptions(context, item, theme),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
