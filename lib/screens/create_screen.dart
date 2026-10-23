import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_bloc.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_event.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_state.dart';
import 'package:scan_master/utils/text_styles.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateCodeBloc(),
      child: const _CreateScreenContent(),
    );
  }
}

class _CreateScreenContent extends StatefulWidget {
  const _CreateScreenContent();

  @override
  State<_CreateScreenContent> createState() => _CreateScreenContentState();
}

class _CreateScreenContentState extends State<_CreateScreenContent> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ImagePicker _picker = ImagePicker();

  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  final _controller3 = TextEditingController();
  final _captionController = TextEditingController();
  String _wifiType = 'WPA';

  @override
  void initState() {
    super.initState();
    _controller1.text = 'https://';
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(CodeCategory category) {
    HapticFeedback.selectionClick();
    _controller1.clear();
    _controller2.clear();
    _controller3.clear();
    if (category == CodeCategory.url) {
      _controller1.text = 'https://';
    }
    context.read<CreateCodeBloc>().add(ChangeCategoryEvent(category));
  }

  void _generate(CodeCategory category) {
    String result = '';

    switch (category) {
      case CodeCategory.url:
      case CodeCategory.text:
      case CodeCategory.code128:
      case CodeCategory.ean13:
      case CodeCategory.upca:
      case CodeCategory.aztec:
        result = _controller1.text.trim();
        break;

      case CodeCategory.upi:
        final pa = _controller1.text.trim();
        final pn = Uri.encodeComponent(_controller2.text.trim());
        final am = _controller3.text.trim();
        result = 'upi://pay?pa=$pa&pn=$pn';
        if (am.isNotEmpty) result += '&am=$am&cu=INR';
        break;

      case CodeCategory.wifi:
        final ssid = _controller2.text.trim();
        final pass = _controller3.text.trim();
        result = 'WIFI:T:$_wifiType;S:$ssid;P:$pass;;';
        break;

      case CodeCategory.contact:
        final name = _controller2.text.trim();
        final phone = _controller1.text.trim();
        result = 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL:$phone\nEND:VCARD';
        break;

      case CodeCategory.email:
        final email = _controller1.text.trim();
        final subject = Uri.encodeComponent(_controller2.text.trim());
        final body = Uri.encodeComponent(_controller3.text.trim());
        result = 'mailto:$email?subject=$subject&body=$body';
        break;

      case CodeCategory.sms:
        final phone = _controller1.text.trim();
        final body = Uri.encodeComponent(_controller2.text.trim());
        result = 'sms:$phone?body=$body';
        break;

      case CodeCategory.phone:
        result = 'tel:${_controller1.text.trim()}';
        break;
    }

    if (result.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid data to generate code'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    context.read<CreateCodeBloc>().add(GenerateCodeEvent(result));
  }

  Future<void> _pickCustomLogo() async {
    HapticFeedback.selectionClick();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        context.read<CreateCodeBloc>().add(
              ChangeLogoTypeEvent(
                LogoType.custom,
                customFile: File(image.path),
              ),
            );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
      );
    }
  }

  Future<void> _saveCode() async {
    try {
      HapticFeedback.mediumImpact();
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/code_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(imageBytes);
        await Gal.putImage(file.path);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code saved to gallery!'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareCode(String data) async {
    try {
      HapticFeedback.mediumImpact();
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              imageBytes,
              mimeType: 'image/png',
              name:
                  'ScanMaster_Generated_${DateTime.now().millisecondsSinceEpoch}.png',
            ),
          ],
          text: data,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          'Generator',
          style: defaultTextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<CreateCodeBloc, CreateCodeState>(
        builder: (context, state) {
          final bloc = context.read<CreateCodeBloc>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              // 1. Format Category Selector (Sleek Segmented Pill Rail)
              _buildSectionHeader('FORMAT CATEGORY', theme),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _formatCategoryPill(CodeCategory.url, Icons.link_rounded,
                        'URL', state.category, theme),
                    _formatCategoryPill(
                        CodeCategory.upi,
                        Icons.currency_rupee_rounded,
                        'UPI / Pay',
                        state.category,
                        theme),
                    _formatCategoryPill(CodeCategory.wifi, Icons.wifi_rounded,
                        'Wi-Fi', state.category, theme),
                    _formatCategoryPill(CodeCategory.contact,
                        Icons.badge_outlined, 'Contact', state.category, theme),
                    _formatCategoryPill(
                        CodeCategory.text,
                        Icons.text_fields_rounded,
                        'Plain Text',
                        state.category,
                        theme),
                    _formatCategoryPill(CodeCategory.email,
                        Icons.email_outlined, 'Email', state.category, theme),
                    _formatCategoryPill(CodeCategory.sms, Icons.sms_outlined,
                        'SMS', state.category, theme),
                    _formatCategoryPill(CodeCategory.phone, Icons.call_rounded,
                        'Phone', state.category, theme),
                    _formatCategoryPill(
                        CodeCategory.code128,
                        CupertinoIcons.barcode,
                        'Code 128',
                        state.category,
                        theme),
                    _formatCategoryPill(
                        CodeCategory.ean13,
                        CupertinoIcons.barcode,
                        'EAN 13',
                        state.category,
                        theme),
                    _formatCategoryPill(CodeCategory.upca,
                        CupertinoIcons.barcode, 'UPC-A', state.category, theme),
                    _formatCategoryPill(
                        CodeCategory.aztec,
                        CupertinoIcons.barcode,
                        'Aztec 2D',
                        state.category,
                        theme),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Payload Form Fields Card
              _buildSectionHeader('PAYLOAD DETAILS', theme),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: _buildFormFields(state.category),
              ),
              const SizedBox(height: 18),

              // 3. Customization Suite
              if (!state.is1DBarcode) ...[
                _buildSectionHeader('CUSTOMIZATION & STYLING', theme),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Center Logo Type Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Center Logo',
                            style: defaultTextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              _buildLogoButton(
                                label: 'None',
                                icon: Icons.block_rounded,
                                isSelected: state.logoType == LogoType.none,
                                onTap: () => bloc
                                    .add(ChangeLogoTypeEvent(LogoType.none)),
                              ),
                              const SizedBox(width: 6),
                              _buildLogoButton(
                                label: 'Default',
                                icon: Icons.qr_code_2_rounded,
                                isSelected:
                                    state.logoType == LogoType.appDefault,
                                onTap: () => bloc.add(
                                    ChangeLogoTypeEvent(LogoType.appDefault)),
                              ),
                              const SizedBox(width: 6),
                              _buildLogoButton(
                                label: 'Custom',
                                icon: Icons.add_photo_alternate_outlined,
                                isSelected: state.logoType == LogoType.custom,
                                onTap: _pickCustomLogo,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Circle vs Rounded Rectangle Shape Picker (visible when logo active)
                      if (state.logoType != LogoType.none) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Logo Shape',
                              style: defaultTextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                _buildShapeToggle(
                                  label: 'Circle',
                                  icon: Icons.circle_outlined,
                                  isSelected:
                                      state.logoShape == LogoShape.circle,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    bloc.add(
                                        UpdateLogoShapeEvent(LogoShape.circle));
                                  },
                                  theme: theme,
                                ),
                                const SizedBox(width: 6),
                                _buildShapeToggle(
                                  label: 'Squircle',
                                  icon: Icons.crop_square_rounded,
                                  isSelected:
                                      state.logoShape == LogoShape.roundedRect,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    bloc.add(UpdateLogoShapeEvent(
                                        LogoShape.roundedRect));
                                  },
                                  theme: theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 14),

                      // QR Matrix Roundness Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pattern Curvature',
                            style: defaultTextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            state.qrRoundFactor == 0.0
                                ? 'Sharp Squares'
                                : '${(state.qrRoundFactor * 100).round()}% Rounded',
                            style: defaultTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: state.qrRoundFactor,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: (val) =>
                              bloc.add(UpdateQrRoundnessEvent(val)),
                        ),
                      ),

                      // Outer Container Radius Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Frame Corner Radius',
                            style: defaultTextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${state.frameCornerRadius.round()} px',
                            style: defaultTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: state.frameCornerRadius,
                          min: 0.0,
                          max: 36.0,
                          divisions: 12,
                          onChanged: (val) =>
                              bloc.add(UpdateFrameRadiusEvent(val)),
                        ),
                      ),

                      // Optional Bottom Label / Caption
                      const SizedBox(height: 10),
                      TextField(
                        controller: _captionController,
                        onChanged: (val) =>
                            bloc.add(UpdateCaptionEvent(val.trim())),
                        decoration: InputDecoration(
                          labelText: 'Bottom Caption / Label (Optional)',
                          hintText: 'e.g. Scan to pay or visit my website',
                          prefixIcon: const Icon(Icons.short_text_rounded),
                          suffixIcon: _captionController.text.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _captionController.clear();
                                    bloc.add(UpdateCaptionEvent(''));
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color Presets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Color Theme',
                            style: defaultTextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              _colorPalettePill(Colors.black, Colors.white,
                                  state.fgColor, state.bgColor, bloc),
                              const SizedBox(width: 8),
                              _colorPalettePill(
                                  const Color(0xFF0D47A1),
                                  const Color(0xFFE3F2FD),
                                  state.fgColor,
                                  state.bgColor,
                                  bloc),
                              const SizedBox(width: 8),
                              _colorPalettePill(
                                  const Color(0xFF311B92),
                                  const Color(0xFFEDE7F6),
                                  state.fgColor,
                                  state.bgColor,
                                  bloc),
                              const SizedBox(width: 8),
                              _colorPalettePill(
                                  const Color(0xFF004D40),
                                  const Color(0xFFE0F2F1),
                                  state.fgColor,
                                  state.bgColor,
                                  bloc),
                              const SizedBox(width: 8),
                              _colorPalettePill(
                                  const Color(0xFFB71C1C),
                                  const Color(0xFFFFEBEE),
                                  state.fgColor,
                                  state.bgColor,
                                  bloc),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 4. Generate CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                  ),
                  onPressed: () => _generate(state.category),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                  label: Text(
                    'Generate Preview',
                    style: defaultTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Rendered Code Canvas & Export Controls
              if (state.generatedPayload.isNotEmpty) ...[
                _buildSectionHeader('RENDERED RESULT', theme),
                Center(
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: state.bgColor,
                        borderRadius:
                            BorderRadius.circular(state.frameCornerRadius),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRenderedBarcode(state),
                          if (state.caption.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.caption,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: state.fgColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Export Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saveCode,
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text('Save to Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _shareCode(state.generatedPayload),
                        icon: const Icon(Icons.share_rounded, size: 20),
                        label: const Text('Share Code'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
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

  // Refined Format Category Pill with tactile elevation and dynamic coloring
  Widget _formatCategoryPill(
    CodeCategory category,
    IconData icon,
    String label,
    CodeCategory selectedCategory,
    ThemeData theme,
  ) {
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onCategoryChanged(category),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: defaultTextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShapeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: defaultTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: defaultTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorPalettePill(
    Color fg,
    Color bg,
    Color currentFg,
    Color currentBg,
    CreateCodeBloc bloc,
  ) {
    final isCurrent = currentFg == fg && currentBg == bg;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        bloc.add(UpdateColorEvent(fgColor: fg, bgColor: bg));
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrent ? theme.colorScheme.primary : Colors.grey.shade400,
            width: isCurrent ? 2.5 : 1.2,
          ),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRenderedBarcode(CreateCodeState state) {
    if (state.is1DBarcode) {
      bw.Barcode barcodeType;
      switch (state.category) {
        case CodeCategory.ean13:
          barcodeType = bw.Barcode.ean13();
          break;
        case CodeCategory.upca:
          barcodeType = bw.Barcode.upcA();
          break;
        default:
          barcodeType = bw.Barcode.code128();
      }

      return bw.BarcodeWidget(
        barcode: barcodeType,
        data: state.generatedPayload,
        width: 250,
        height: 100,
        color: state.fgColor,
        backgroundColor: state.bgColor,
        drawText: true,
        errorBuilder: (context, error) => const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Invalid characters for format',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      );
    }

    if (state.category == CodeCategory.aztec) {
      return bw.BarcodeWidget(
        barcode: bw.Barcode.aztec(),
        data: state.generatedPayload,
        width: 180,
        height: 180,
        color: state.fgColor,
        backgroundColor: state.bgColor,
      );
    }

    // Embed and style center logo with dynamic clipping
    ImageProvider? logoProvider;
    if (state.logoType == LogoType.appDefault) {
      logoProvider = const AssetImage('assets/play_store_512.png');
    } else if (state.logoType == LogoType.custom &&
        state.customLogoFile != null) {
      logoProvider = FileImage(state.customLogoFile!);
    }

    final qrShape = state.qrRoundFactor > 0.0
        ? PrettyQrSmoothSymbol(
            color: state.fgColor,
            roundFactor: state.qrRoundFactor,
          )
        : PrettyQrSquaresSymbol(
            color: state.fgColor,
          );

    return SizedBox(
      width: 190,
      height: 190,
      child: PrettyQrView.data(
        data: state.generatedPayload,
        decoration: PrettyQrDecoration(
          shape: qrShape,
          background: state.bgColor,
          image: logoProvider != null
              ? PrettyQrDecorationImage(
                  image: logoProvider,
                  position: PrettyQrDecorationImagePosition.embedded,
                  fit: BoxFit.cover,
                  padding: const EdgeInsets.all(4),
                  clipper: state.logoShape == LogoShape.circle
                      ? const PrettyQrCircleClipper()
                      : const PrettyQrRectangleClipper(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFormFields(CodeCategory category) {
    switch (category) {
      case CodeCategory.url:
        return TextField(
          controller: _controller1,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Website Address',
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link_rounded),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        );

      case CodeCategory.upi:
        return Column(
          children: [
            TextField(
              controller: _controller1,
              decoration: const InputDecoration(
                labelText: 'UPI ID / VPA',
                hintText: 'name@okhdfcbank',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Payee Name',
                hintText: 'Recipient or Merchant Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller3,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Default Amount (Optional)',
                hintText: '0.00',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
          ],
        );

      case CodeCategory.wifi:
        return Column(
          children: [
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Network Name (SSID)',
                prefixIcon: Icon(Icons.wifi_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller3,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'WPA', label: Text('WPA/WPA2')),
                ButtonSegment(value: 'WEP', label: Text('WEP')),
                ButtonSegment(value: 'nopass', label: Text('Open')),
              ],
              selected: {_wifiType},
              onSelectionChanged: (val) =>
                  setState(() => _wifiType = val.first),
            ),
          ],
        );

      case CodeCategory.contact:
        return Column(
          children: [
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Contact Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller1,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
          ],
        );

      case CodeCategory.email:
        return Column(
          children: [
            TextField(
              controller: _controller1,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller3,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                prefixIcon: Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
          ],
        );

      case CodeCategory.sms:
        return Column(
          children: [
            TextField(
              controller: _controller1,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller2,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Preset Message',
                prefixIcon: Icon(Icons.sms_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),
          ],
        );

      case CodeCategory.phone:
        return TextField(
          controller: _controller1,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+91 98765 43210',
            prefixIcon: Icon(Icons.phone_rounded),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        );

      case CodeCategory.text:
      case CodeCategory.code128:
      case CodeCategory.ean13:
      case CodeCategory.upca:
      case CodeCategory.aztec:
        return TextField(
          controller: _controller1,
          maxLines: category == CodeCategory.text ? 4 : 1,
          decoration: InputDecoration(
            labelText: (category == CodeCategory.code128 ||
                    category == CodeCategory.ean13 ||
                    category == CodeCategory.upca)
                ? 'Barcode Value'
                : 'Text Content',
            hintText: category == CodeCategory.ean13
                ? '13-digit numeric string'
                : 'Enter content to encode',
            prefixIcon: Icon((category == CodeCategory.code128 ||
                    category == CodeCategory.ean13 ||
                    category == CodeCategory.upca)
                ? CupertinoIcons.barcode
                : Icons.text_fields_rounded),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
          ),
        );
    }
  }
}
