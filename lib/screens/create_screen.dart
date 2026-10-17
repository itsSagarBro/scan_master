import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_master/utils/text_styles.dart';

/// allows users to select a barcode format or structured data schema
/// such as url, wi-fi, contact vcard, or 1d barcodes to generate custom codes.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create',
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
                  // standard data types
                  _buildTypeChip(
                    context,
                    icon: Icons.link_rounded,
                    text: 'URL',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.text_fields_rounded,
                    text: 'Text',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.email_outlined,
                    text: 'Email',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.person_outline_rounded,
                    text: 'Contact',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.sms_outlined,
                    text: 'SMS',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.call_rounded,
                    text: 'Phone',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.wifi_rounded,
                    text: 'Wi-Fi',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.calendar_month_rounded,
                    text: 'Calendar',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: Icons.location_on_outlined,
                    text: 'Geo',
                    onPressed: () {},
                  ),

                  // 1d and 2d barcode symbologies
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'EAN_8',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'EAN_13',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'UPC_E',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'UPC_A',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'CODE_39',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'CODE_93',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'CODE_128',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'ITF',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'PDF_417',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'CODABAR',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'DATA_MATRIX',
                    onPressed: () {},
                  ),
                  _buildTypeChip(
                    context,
                    icon: CupertinoIcons.barcode,
                    text: 'AZTEC',
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

  /// helper widget rendering an interactive selection chip for code generation types
  Widget _buildTypeChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return RawChip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      avatar: Icon(
        icon,
        color: theme.colorScheme.onSurface,
        size: 22,
      ),
      label: Text(
        text,
        style: defaultTextStyle(),
      ),
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      onPressed: onPressed,
    );
  }
}
