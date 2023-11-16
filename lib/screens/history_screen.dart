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

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "History",
          style: appBarHeading(),
        ),
        titleSpacing: 5,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.datas.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              ScannedModel scannedModel =
                  ScannedModel.fromJson(state.datas[index]);
              Barcode barcode = (scannedModel.raw as List)
                  .map((e) => Barcode.fromNative(e as Map))
                  .toList()
                  .first;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Slidable(
                  endActionPane:
                      ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: (context) =>
                          BlocProvider.of<HistoryBloc>(context)
                              .add(DeleteHistory(index)),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: BorderRadius.circular(20),
                    )
                  ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          context.go("/history/scanned", extra: scannedModel),
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(.5),
                        constraints:
                            const BoxConstraints(maxHeight: 140, minHeight: 80),
                        child: Row(
                          children: [
                            Expanded(
                                child: AutoSizeText.rich(
                              TextSpan(
                                  style: defaultTextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                          .withOpacity(.5)),
                                  children: [
                                    TextSpan(
                                        text:
                                            "${barcode.type.name.toUpperCase()}\n",
                                        style: defaultTextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground)
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                    TextSpan(
                                        text:
                                            "${formattedTime(DateTime.parse(scannedModel.datetime!))}, ${barcode.format.name.toUpperCase()}"),
                                    TextSpan(
                                        text: "\n${getDisplayValue(barcode)}")
                                  ]),
                              minFontSize: 12,
                            ))
                          ],
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

  String formattedTime(DateTime dateTime) {
    String fTime = "";

    fTime =
        "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour % 12}:${dateTime.minute}:${dateTime.second} ${(dateTime.hour < 12) ? "AM" : "PM"}";

    return fTime;
  }
}
