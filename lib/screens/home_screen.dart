import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scan_master/bloc/history_bloc/history_bloc.dart';
import 'package:scan_master/bloc/qr_scanner_bloc/qr_scanner_bloc.dart';
import 'package:scan_master/bloc/settings_bloc/settings_bloc.dart';
import 'package:scan_master/models/history_model.dart';
import 'package:scan_master/utils/qr_scanner_overlay.dart';
import 'package:scan_master/utils/text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  final ImagePicker _picker = ImagePicker();
  bool _isNavigating = false;

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOutQuad,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      if (uri.queryParameters['action'] == 'gallery') {
        final controller =
            context.read<QrScannerBloc>().state.mobileScannerController;
        _pickAndScanFromGallery(controller);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<QrScannerBloc>().add(OnReturn(fromBackground: true));
      if (!_laserController.isAnimating) _laserController.repeat(reverse: true);
    } else if (state == AppLifecycleState.paused) {
      _laserController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _laserController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadScreen(String routeName) async {
    final scannerBloc = context.read<QrScannerBloc>();
    scannerBloc.add(PauseCamera());
    _laserController.stop();

    await context.push(routeName);

    if (!mounted) return;
    _laserController.repeat(reverse: true);
    scannerBloc.add(StartCamera());
  }

  Future<void> _pickAndScanFromGallery(
      MobileScannerController? controller) async {
    if (controller == null || _isNavigating) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return;

      final capture = await controller.analyzeImage(image.path);

      if (!mounted) return;

      if (capture != null && capture.barcodes.isNotEmpty) {
        final firstBarcode = capture.barcodes.first;
        final scannedModel = ScannedModel.fromBarcode(
          firstBarcode,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        if (context.read<SettingsBloc>().saveHistory) {
          context.read<HistoryBloc>().add(OnAddHistoryClicked(capture));
        }
        context.read<QrScannerBloc>().add(OnScannedData(scannedModel));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No QR or barcode detected in image'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to read image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final cutoutDimension = size.width * 0.68;

    return BlocConsumer<QrScannerBloc, QrScannerState>(
      listenWhen: (previous, current) => current.data != null,
      listener: (context, state) async {
        final data = state.data;
        if (data != null && !_isNavigating) {
          _isNavigating = true;
          _laserController.stop();
          HapticFeedback.selectionClick();

          final scannerBloc = context.read<QrScannerBloc>();

          dynamic targetPayload = data;
          if (targetPayload is BarcodeCapture &&
              targetPayload.barcodes.isNotEmpty) {
            targetPayload = ScannedModel.fromBarcode(
              targetPayload.barcodes.first,
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            );
          }

          try {
            await context.push('/scanned', extra: targetPayload);
          } finally {
            if (mounted) {
              _isNavigating = false;
              if (!_laserController.isAnimating) {
                _laserController.repeat(reverse: true);
              }
              scannerBloc.add(OnReturn());
            }
          }
        }
      },
      builder: (context, state) {
        final isFlashOn = state.flashOn ?? false;
        final controller = state.mobileScannerController;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera View
              if (controller != null)
                MobileScanner(
                  key: _qrKey,
                  controller: controller,
                  onDetect: (barcodes) {
                    if (_isNavigating || barcodes.barcodes.isEmpty) return;

                    final first = barcodes.barcodes.first;
                    final payload = first.rawValue ?? first.displayValue ?? '';
                    if (payload.trim().isEmpty) return;

                    final scannedModel = ScannedModel.fromBarcode(
                      first,
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    );

                    if (context.read<SettingsBloc>().saveHistory) {
                      context
                          .read<HistoryBloc>()
                          .add(OnAddHistoryClicked(barcodes));
                    }
                    context
                        .read<QrScannerBloc>()
                        .add(OnScannedData(scannedModel));
                  },
                  overlayBuilder: (context, _) {
                    return AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: ShapeDecoration(
                            shape: QrScannerOverlay(
                              borderColor: theme.colorScheme.primary,
                              borderWidth: 3.5 * _pulseAnimation.value,
                              borderLength: 28,
                              borderRadius: 24,
                              cutOutSize: cutoutDimension,
                              overlayColor:
                                  Colors.black.withValues(alpha: 0.65),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              // 2. Animated Laser Sweep
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: cutoutDimension - 24,
                    height: cutoutDimension - 24,
                    child: AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, _) {
                        return Align(
                          alignment: Alignment(
                            0,
                            -1.0 + (2.0 * _laserAnimation.value),
                          ),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.0),
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 3. Status Hint Pill
              Positioned(
                top: (size.height / 2) - (cutoutDimension / 2) - 46,
                left: 20,
                right: 20,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Point camera at code',
                              style: defaultTextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Balanced Top Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                'Scan Master',
                                style: defaultTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              height: 44,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildInnerIconButton(
                                    icon: Icons.photo_library_outlined,
                                    tooltip: 'Scan from gallery',
                                    onTap: () =>
                                        _pickAndScanFromGallery(controller),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                  _buildInnerIconButton(
                                    icon: isFlashOn
                                        ? Icons.flash_on_rounded
                                        : Icons.flash_off_rounded,
                                    iconColor:
                                        isFlashOn ? Colors.amber : Colors.white,
                                    tooltip:
                                        isFlashOn ? 'Torch off' : 'Torch on',
                                    onTap: () => context
                                        .read<QrScannerBloc>()
                                        .add(OnFlashClick()),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                  _buildInnerIconButton(
                                    icon: Icons.settings_outlined,
                                    tooltip: 'Settings',
                                    onTap: () => _loadScreen('/settings'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Floating Bottom Navigation Dock
              Positioned(
                bottom: 26,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surface.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDockButton(
                            theme: theme,
                            icon: Icons.history_rounded,
                            label: 'History',
                            onTap: () => _loadScreen('/history'),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 1,
                            ),
                            onPressed: () => _loadScreen('/create'),
                            icon: const Icon(Icons.qr_code_2_rounded, size: 21),
                            label: Text(
                              'Generate',
                              style: defaultTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          _buildDockButton(
                            theme: theme,
                            icon: Icons.star_rounded,
                            label: 'Starred',
                            onTap: () => _loadScreen('/favorites'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInnerIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDockButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: defaultTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
