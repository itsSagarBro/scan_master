import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_master/utils/text_styles.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create",
          style: appBarHeading(),
        ),
        titleSpacing: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Wrap(
                spacing: 10,
                runSpacing: 5,
                children: [
                  chip(
                    context,
                    icon: Icons.link_rounded,
                    text: "URL",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.text_fields_rounded,
                    text: "Text",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.email_outlined,
                    text: "Email",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.person_outline_rounded,
                    text: "Contact",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.sms_outlined,
                    text: "SMS",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.call_rounded,
                    text: "Phone",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.wifi_rounded,
                    text: "Wifi",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.calendar_month_rounded,
                    text: "Calender",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: Icons.location_on_outlined,
                    text: "Geo",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "EAN_8",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "EAN_13",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "UPC_E",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "UPC_A",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "CODE_39",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "CODE_93",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "CODE_128",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "ITF",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "PDF_417",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "CODABAR",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "DATA_MATRIX",
                    onPressed: () {},
                  ),
                  chip(
                    context,
                    icon: const IconData(0xf586,
                        fontFamily: CupertinoIcons.iconFont,
                        fontPackage: CupertinoIcons.iconFontPackage),
                    text: "AZTEC",
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  RawChip chip(BuildContext context,
      {required IconData icon,
      required String text,
      required Function() onPressed}) {
    return RawChip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      avatar: Icon(
        icon,
        color: Theme.of(context).colorScheme.onBackground,
        size: 22,
      ),
      label: Text(
        text,
        style: defaultTextStyle(),
      ),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onPressed: onPressed,
    );
  }
}
