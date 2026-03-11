import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LaundryBasketPainter extends CustomPainter {
  final double fillPercent; // 0.0 - 1.0
  final String riskLevel;
  final int pileCount;
  final String emoji;

  LaundryBasketPainter({
    required this.fillPercent,
    required this.riskLevel,
    required this.pileCount,
    required this.emoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Basket body path (trapezoid shape - wider at top, narrower at bottom with rounded bottom)
    final basketPath = Path();
    final topInset = w * 0.05;
    final bottomInset = w * 0.15;
    final rimHeight = h * 0.12;

    // Basket body (below rim)
    basketPath.moveTo(topInset, rimHeight);
    basketPath.lineTo(bottomInset, h - 20);
    basketPath.quadraticBezierTo(bottomInset, h, bottomInset + 20, h);
    basketPath.lineTo(w - bottomInset - 20, h);
    basketPath.quadraticBezierTo(w - bottomInset, h, w - bottomInset, h - 20);
    basketPath.lineTo(w - topInset, rimHeight);
    basketPath.close();

    // Basket rim
    final rimPath = Path();
    rimPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, rimHeight),
      const Radius.circular(8),
    ));

    // Draw basket shadow
    canvas.drawShadow(basketPath, Colors.black26, 6, false);

    // Draw basket body bg
    final basketBgPaint = Paint()
      ..color = const Color(0xFFF0F4F8)
      ..style = PaintingStyle.fill;
    canvas.drawPath(basketPath, basketBgPaint);

    // Draw fill level inside basket
    if (fillPercent > 0) {
      Color fillColor;
      switch (riskLevel) {
        case 'critical':
          fillColor = AppColors.basketRed;
          break;
        case 'warning':
          fillColor = AppColors.basketYellow;
          break;
        default:
          fillColor = AppColors.basketBlue;
      }

      // Clip to basket shape
      canvas.save();
      canvas.clipPath(basketPath);

      final fillTop = rimHeight + (h - rimHeight) * (1.0 - fillPercent);

      // Draw fill with wavy top
      final fillPath = Path();
      fillPath.moveTo(0, fillTop);
      // Wavy top
      for (double x = 0; x <= w; x += 1) {
        final y = fillTop + sin(x * 0.08) * 4;
        fillPath.lineTo(x, y);
      }
      fillPath.lineTo(w, h);
      fillPath.lineTo(0, h);
      fillPath.close();

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      canvas.restore();
    }

    // Basket weave pattern (horizontal lines)
    final weavePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.save();
    canvas.clipPath(basketPath);
    for (double y = rimHeight + 12; y < h; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(w, y), weavePaint);
    }
    canvas.restore();

    // Basket outline
    final outlinePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(basketPath, outlinePaint);

    // Draw rim
    final rimPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawPath(rimPath, rimPaint);

    // Rim highlight
    final rimHighlight = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 2, w - 8, rimHeight * 0.4),
        const Radius.circular(4),
      ),
      rimHighlight,
    );
  }

  @override
  bool shouldRepaint(covariant LaundryBasketPainter old) =>
      old.fillPercent != fillPercent ||
      old.riskLevel != riskLevel ||
      old.pileCount != pileCount;
}
