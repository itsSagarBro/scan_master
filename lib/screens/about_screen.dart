import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _repoUrl = 'https://github.com/itsSagarBro/scan_master';
  static const String _issuesUrl =
      'https://github.com/itsSagarBro/scan_master/issues';
  static const String _developerUrl = 'https://github.com/itsSagarBro';

  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (_) {
      // Fallback defaults preserved on desktop/unsupported runtimes
    }
  }

  Future<void> _requestReview() async {
    HapticFeedback.selectionClick();
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(
        appStoreId: 'dev.sagarpatel.scanmaster',
      );
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          'About',
          style: defaultTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Rate on Store',
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rate_rounded,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              onPressed: _requestReview,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          // 1. Hero Brand Header
          Center(
            child: Column(
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/play_store_512.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan Master',
                  style: defaultTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                // Dynamic Version Capsule Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'v$_version ($_buildNumber)',
                    style: defaultTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'High-performance, privacy-focused barcode and QR code scanner and generator. Fully functional offline with persistent history and customization.',
                    textAlign: TextAlign.center,
                    style: defaultTextStyle(
                      fontSize: 13,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 2. Links & Community Section
          _buildSectionHeader('SUPPORT & COMMUNITY', theme),
          _buildCardContainer(
            theme,
            children: [
              _buildActionRow(
                theme: theme,
                icon: Icons.star_outline_rounded,
                title: 'Rate & Review',
                subtitle: 'Leave feedback on Google Play Store',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: _requestReview,
              ),
              _buildDivider(theme),
              _buildActionRow(
                theme: theme,
                icon: Icons.code_rounded,
                title: 'Source Code',
                subtitle: 'Explore the repository on GitHub',
                trailing: const Icon(Icons.open_in_new_rounded, size: 16),
                onTap: () => _launchExternalUrl(_repoUrl),
              ),
              _buildDivider(theme),
              _buildActionRow(
                theme: theme,
                icon: Icons.bug_report_outlined,
                title: 'Report an Issue',
                subtitle: 'Submit bugs or request features',
                trailing: const Icon(Icons.open_in_new_rounded, size: 16),
                onTap: () => _launchExternalUrl(_issuesUrl),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3. Legal & Licenses Section
          _buildSectionHeader('LEGAL & LICENSES', theme),
          _buildCardContainer(
            theme,
            children: [
              _buildActionRow(
                theme: theme,
                icon: Icons.description_outlined,
                title: 'Open Source Licenses',
                subtitle: 'Third-party libraries and software notices',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  showLicensePage(
                    context: context,
                    applicationName: 'Scan Master',
                    applicationVersion: 'v$_version',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/play_store_512.png',
                          width: 64,
                          height: 64,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.qr_code_2, size: 64),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Developer Credit Card
          _buildSectionHeader('DEVELOPER', theme),
          Material(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _launchExternalUrl(_developerUrl),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          'SP',
                          style: defaultTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sagar Patel',
                            style: defaultTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lead Full-Stack & Flutter Developer',
                            style: defaultTextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildActionRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
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
              const SizedBox(width: 8),
              trailing,
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
