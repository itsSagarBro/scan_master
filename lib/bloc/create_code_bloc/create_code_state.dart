import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_bloc.dart';

class CreateCodeState {
  final CodeCategory category;
  final Color fgColor;
  final Color bgColor;
  final double qrRoundFactor;
  final double frameCornerRadius;
  final LogoShape logoShape;
  final LogoType logoType;
  final File? customLogoFile;
  final String caption;
  final String generatedPayload;

  const CreateCodeState({
    this.category = CodeCategory.url,
    this.fgColor = Colors.black,
    this.bgColor = Colors.white,
    this.qrRoundFactor = 0.75,
    this.frameCornerRadius = 24.0,
    this.logoShape = LogoShape.circle,
    this.logoType = LogoType.none,
    this.customLogoFile,
    this.caption = '',
    this.generatedPayload = '',
  });

  bool get is1DBarcode =>
      category == CodeCategory.code128 ||
      category == CodeCategory.ean13 ||
      category == CodeCategory.upca;

  CreateCodeState copyWith({
    CodeCategory? category,
    Color? fgColor,
    Color? bgColor,
    double? qrRoundFactor,
    double? frameCornerRadius,
    LogoShape? logoShape,
    LogoType? logoType,
    File? customLogoFile,
    bool clearCustomLogo = false,
    String? caption,
    String? generatedPayload,
  }) {
    return CreateCodeState(
      category: category ?? this.category,
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      qrRoundFactor: qrRoundFactor ?? this.qrRoundFactor,
      frameCornerRadius: frameCornerRadius ?? this.frameCornerRadius,
      logoShape: logoShape ?? this.logoShape,
      logoType: logoType ?? this.logoType,
      customLogoFile:
          clearCustomLogo ? null : (customLogoFile ?? this.customLogoFile),
      caption: caption ?? this.caption,
      generatedPayload: generatedPayload ?? this.generatedPayload,
    );
  }
}
