import 'dart:math';

import 'package:flutter/material.dart';

/// a custom [ShapeBorder] that renders a darkened camera viewfinder overlay
/// with a transparent cutout and framed corner reticles for qr or barcode scanning.
class QrScannerOverlay extends ShapeBorder {
  QrScannerOverlay({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
    double? cutOutWidth,
    double? cutOutHeight,
    this.cutOutBottomOffset = 0,
  })  : cutOutWidth = cutOutWidth ?? cutOutSize ?? 250,
        cutOutHeight = cutOutHeight ?? cutOutSize ?? 250 {
    assert(
      borderLength <=
          min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2,
      "Border can't be larger than ${min(this.cutOutWidth, this.cutOutHeight) / 2 + borderWidth * 2}",
    );
    assert(
      (cutOutWidth == null && cutOutHeight == null) ||
          (cutOutSize == null && cutOutWidth != null && cutOutHeight != null),
      'Use only cutOutWidth and cutOutHeight or only cutOutSize',
    );
  }

  /// stroke color of the scanner viewfinder corners
  final Color borderColor;

  /// thickness of the corner reticle lines
  final double borderWidth;

  /// background tint color applied outside the scanner cutout area
  final Color overlayColor;

  /// corner radius applied to both the cutout window and the bounding reticle corners
  final double borderRadius;

  /// length of the horizontal and vertical edges forming each viewfinder corner
  final double borderLength;

  /// horizontal width of the transparent scan target window
  final double cutOutWidth;

  /// vertical height of the transparent scan target window
  final double cutOutHeight;

  /// vertical positional offset from center, allowing the cutout to sit slightly higher
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;

    // ensure corner border length stays within half the dimensions of the cutout box
    final bl =
        borderLength > min(cutOutWidth, cutOutHeight) / 2 + borderWidth * 2
            ? borderWidthSize / 2
            : borderLength;
    final cow = cutOutWidth < width ? cutOutWidth : width - borderOffset;
    final coh = cutOutHeight < height ? cutOutHeight : height - borderOffset;

    // overlay shade paint
    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // corner frame reticle paint
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // punch-through paint using dstOut blend mode to punch the transparent hole
    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    // calculate centered cutout position taking bottom offset into account
    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cow / 2 + borderOffset,
      -cutOutBottomOffset + rect.top + height / 2 - coh / 2 + borderOffset,
      cow - borderOffset * 2,
      coh - borderOffset * 2,
    );

    // render overlay, draw corner highlights, then cut out the center window
    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      // draw top right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - bl,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + bl,
          topRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // draw top left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + bl,
          cutOutRect.top + bl,
          topLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // draw bottom right corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.right - bl,
          cutOutRect.bottom - bl,
          cutOutRect.right,
          cutOutRect.bottom,
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // draw bottom left corner
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          cutOutRect.left,
          cutOutRect.bottom - bl,
          cutOutRect.left + bl,
          cutOutRect.bottom,
          bottomLeft: Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      // clear the transparent window inside the overlay
      ..drawRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlay(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutWidth: cutOutWidth * t,
      cutOutHeight: cutOutHeight * t,
      cutOutBottomOffset: cutOutBottomOffset * t,
    );
  }
}
