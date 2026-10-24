import 'package:flutter/material.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:scan_master/utils/url_safety_helper.dart';

class UrlSafetyCard extends StatefulWidget {
  final String rawUrl;

  const UrlSafetyCard({super.key, required this.rawUrl});

  @override
  State<UrlSafetyCard> createState() => _UrlSafetyCardState();
}

class _UrlSafetyCardState extends State<UrlSafetyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final components = UrlSafetyHelper.parseUrl(widget.rawUrl);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (components == null) {
      return SelectableText(
        widget.rawUrl,
        style: defaultTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    final isSuspicious = components.isSuspiciousStructure;
    final isHttps = components.scheme.toLowerCase().contains('https');

    final Color statusColor =
        isSuspicious ? theme.colorScheme.error : theme.colorScheme.primary;

    final Color warningAmber =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Status Bar: Ambient Indicator + Security Badges
        Row(
          children: [
            // Ambient Status Dot
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: _pulseAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(
                          alpha: _pulseAnimation.value * 0.5,
                        ),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // Main Security Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                isSuspicious ? 'DECEPTIVE LINK' : 'DESTINATION HOST',
                style: defaultTextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Protocol Chip (HTTPS / HTTP)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: (isHttps ? Colors.teal : Colors.deepOrange)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (isHttps ? Colors.teal : Colors.deepOrange)
                      .withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Text(
                isHttps ? 'HTTPS' : 'HTTP',
                style: defaultTextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isHttps
                      ? (isDark ? Colors.tealAccent : Colors.teal.shade800)
                      : Colors.deepOrangeAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2. Primary Hero: Registrable Root Domain
        Text(
          components.rootDomain,
          style: defaultTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isSuspicious ? statusColor : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),

        // 3. Monospaced URL Breakdown (Fits naturally into the glass parent)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: SelectableText.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.45,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              children: [
                // Scheme (e.g. https://)
                TextSpan(text: components.scheme),

                // Subdomain (Highlighted in warning amber if deceptive)
                if (components.subdomain.isNotEmpty)
                  TextSpan(
                    text: components.subdomain,
                    style: TextStyle(
                      color: isSuspicious
                          ? warningAmber
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSuspicious ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),

                // Root Target (Bold and colored)
                TextSpan(
                  text: components.rootDomain,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),

                // Path & Query Parameters
                if (components.pathAndQuery.isNotEmpty)
                  TextSpan(text: components.pathAndQuery),
              ],
            ),
          ),
        ),

        // 4. Subtle Context Note for Flagged URLs
        if (isSuspicious) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'A trusted brand keyword is masked inside a third-party host.',
                  style: defaultTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
