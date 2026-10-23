import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scan_master/bloc/create_code_bloc/create_code_bloc.dart';

abstract class CreateCodeEvent {}

class ChangeCategoryEvent extends CreateCodeEvent {
  final CodeCategory category;
  ChangeCategoryEvent(this.category);
}

class UpdateColorEvent extends CreateCodeEvent {
  final Color fgColor;
  final Color bgColor;
  UpdateColorEvent({required this.fgColor, required this.bgColor});
}

class UpdateQrRoundnessEvent extends CreateCodeEvent {
  final double roundFactor;
  UpdateQrRoundnessEvent(this.roundFactor);
}

class UpdateFrameRadiusEvent extends CreateCodeEvent {
  final double radius;
  UpdateFrameRadiusEvent(this.radius);
}

class UpdateLogoShapeEvent extends CreateCodeEvent {
  final LogoShape shape;
  UpdateLogoShapeEvent(this.shape);
}

class ChangeLogoTypeEvent extends CreateCodeEvent {
  final LogoType logoType;
  final File? customFile;
  ChangeLogoTypeEvent(this.logoType, {this.customFile});
}

class UpdateCaptionEvent extends CreateCodeEvent {
  final String caption;
  UpdateCaptionEvent(this.caption);
}

class GenerateCodeEvent extends CreateCodeEvent {
  final String payload;
  GenerateCodeEvent(this.payload);
}
