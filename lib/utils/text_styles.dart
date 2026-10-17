import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// base font family used across the application
final TextStyle _baseStyle = GoogleFonts.poppins();

/// text style applied to standard app bar titles
TextStyle appBarHeading() {
  return _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
}

/// text style applied to floating overlays and action captions
TextStyle centerFloatingHeading() {
  return _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

/// text style used on primary call-to-action buttons such as qr actions
TextStyle qrOpenButtonTextStyle() {
  return _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
}

/// flexible helper for standard body content across pages
///
/// allows optional overrides for font size, color, and font weight
TextStyle defaultTextStyle({
  double fontSize = 16.0,
  Color? color,
  FontWeight? fontWeight,
}) {
  return _baseStyle.copyWith(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}

/// text style used for navigation drawer item labels
TextStyle drawerTextStyle({Color? color}) {
  return _baseStyle.copyWith(
    fontSize: 26,
    color: color,
  );
}
