import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle _defaultFontStyle = GoogleFonts.poppins();

TextStyle appBarHeading() {
  return _defaultFontStyle.copyWith(fontSize: 20);
}

TextStyle centerFloatingHeading() {
  return _defaultFontStyle.copyWith(fontSize: 16);
}

TextStyle qrOpenButtonTextStyle() {
  return _defaultFontStyle.copyWith(fontSize: 20);
}

TextStyle defaultTextStyle({double? fontSize, Color? color}) {
  return _defaultFontStyle.copyWith(fontSize: fontSize ?? 16, color: color);
}
