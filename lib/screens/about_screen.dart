import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _repoUrl = 'https://github.com/itsSagarBro/scan_master';
  static const String _issuesUrl =
      'https://github.com/itsSagarBro/scan_master/issues';

  Future<void> _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(
        appStoreId: 'com.untitledstudio.scan_master',
      );
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'About',
          style: appBarHeading(),
        ),
        actions: [
          IconButton(
            tooltip: 'Rate App',
            icon: const Icon(Icons.star_rate_rounded),
            onPressed: _requestReview,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/play_store_512.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Name & Version Badge
            Text(
              'Scan Master',
              style: defaultTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v1.0.0',
                style: defaultTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Description
            Text(
              'A fast, offline-first barcode and QR code scanner and generator. '
              'Scan codes instantly, manage saved history, bookmark favorites, '
              'and export custom QR codes tailored for links, Wi-Fi, and contacts.',
              textAlign: TextAlign.center,
              style: defaultTextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 28),

            // Navigation & Action Cards
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded),
                    title: Text('Rate & Review',
                        style: defaultTextStyle(fontSize: 15)),
                    subtitle: Text('Support development on the Play Store',
                        style: defaultTextStyle(
                            fontSize: 12, color: theme.colorScheme.outline)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _requestReview,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.code_rounded),
                    title: Text('Source Code',
                        style: defaultTextStyle(fontSize: 15)),
                    subtitle: Text('GitHub repository',
                        style: defaultTextStyle(
                            fontSize: 12, color: theme.colorScheme.outline)),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () => _launchExternalUrl(_repoUrl),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text('Report an Issue',
                        style: defaultTextStyle(fontSize: 15)),
                    subtitle: Text('Submit bugs or feature requests',
                        style: defaultTextStyle(
                            fontSize: 12, color: theme.colorScheme.outline)),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () => _launchExternalUrl(_issuesUrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Footer
            Text(
              'Designed & Developed by',
              style: defaultTextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sagar Patel',
              style: defaultTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
