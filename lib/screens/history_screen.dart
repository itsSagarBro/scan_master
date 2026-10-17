import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/utils/get_scanned_values.dart';
import 'package:scan_master/utils/text_styles.dart';

/// displays the list of previously scanned codes with swipeable actions
/// to toggle favorites or remove records from persistent local storage.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'History',
          style: appBarHeading(),
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Text(
                  'Clear All',
                  style: defaultTextStyle(fontSize: 14),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear_all') {
                context.read<HistoryBloc>().add(OnDeleteAllHistoryClicked());
              }
            },
            position: PopupMenuPosition.under,
            enableFeedback: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state.datas.isEmpty) {
            return Center(
              child: Text(
                'No scan history found',
                style: defaultTextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.datas.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              final scannedModel = ScannedModel.fromJson(state.datas[index]);
              final barcode = (scannedModel.raw as List)
                  .map((e) => Barcode.fromNative(e as Map))
                  .toList()
                  .first;

              final isFavorite = scannedModel.favorite ?? false;
              final scannedId = scannedModel.id;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.7,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          if (scannedId != null) {
                            context
                                .read<HistoryBloc>()
                                .add(OnFavoriteToggleClicked(scannedId));
                          }
                        },
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        icon: isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        label: 'Favorite',
                        borderRadius: BorderRadius.circular(20),
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          if (scannedId != null) {
                            context
                                .read<HistoryBloc>()
                                .add(OnDeleteHistoryClicked(scannedId));
                          }
                        },
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          context.push('/history/scanned', extra: scannedModel),
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 20,
                        ),
                        color: theme.colorScheme.secondaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 140,
                          minHeight: 80,
                        ),
                        child: AutoSizeText.rich(
                          TextSpan(
                            style: defaultTextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            children: [
                              TextSpan(
                                text: '${barcode.type.name.toUpperCase()}\n',
                                style: defaultTextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text:
                                    '${_formattedTime(DateTime.parse(scannedModel.datetime!))}, ${barcode.format.name.toUpperCase()}',
                              ),
                              TextSpan(
                                text: '\n${getDisplayValue(barcode)}',
                              ),
                            ],
                          ),
                          minFontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// converts a [DateTime] into a formatted date and 12-hour time representation
  /// with zero-padded minutes and seconds
  String _formattedTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute:$second $period';
  }
}
