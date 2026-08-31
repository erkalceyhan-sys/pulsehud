import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hud_metrics.dart';

class MatrixPainter extends CustomPainter {
  final HudMetrics metrics;
  final double animationValue;

  MatrixPainter({required this.metrics, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Digital rain simulation columns
    final rand = Random(42);
    for (double x = 10; x < size.width; x += 24) {
      double speed = rand.nextDouble() * 200 + 150;
      double offset = (animationValue * speed) % size.height;

      canvas.drawLine(
        Offset(x, offset),
        Offset(x, (offset + 60).clamp(0.0, size.height)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF00FF66).withValues(alpha: 0.0),
              const Color(0xFF00FF66).withValues(alpha: 0.7),
            ],
          ).createShader(Rect.fromLTWH(x, offset, 2, 60))
          ..strokeWidth = 2.0,
      );
    }

    // Outer framing brackets
    final bracketPaint = Paint()
      ..color = const Color(0xFF00FF66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left
    canvas.drawLine(const Offset(30, 80), const Offset(80, 80), bracketPaint);
    canvas.drawLine(const Offset(30, 80), const Offset(30, 130), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - 30, size.height - 80),
        Offset(size.width - 80, size.height - 80), bracketPaint);
    canvas.drawLine(Offset(size.width - 30, size.height - 80),
        Offset(size.width - 30, size.height - 130), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant MatrixPainter oldDelegate) => true;
}
