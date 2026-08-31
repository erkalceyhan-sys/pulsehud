import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hud_metrics.dart';

class ObsidianPainter extends CustomPainter {
  final HudMetrics metrics;
  final double animationValue;

  ObsidianPainter({required this.metrics, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    // Dynamically scale stroke width and radius based on container size
    final strokeWidth = (maxRadius * 0.16).clamp(3.0, 14.0);
    final spacing = strokeWidth * 1.35;

    final trackPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Ring 1: CPU (Red)
    final r1 = maxRadius - (strokeWidth / 2);
    if (r1 > 0) {
      canvas.drawCircle(center, r1, trackPaint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r1),
        -pi / 2,
        (metrics.cpuUsage / 100.0) * 2 * pi,
        false,
        Paint()
          ..color = const Color(0xFFFF453A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ring 2: RAM (Green)
    final r2 = r1 - spacing;
    if (r2 > 0) {
      canvas.drawCircle(center, r2, trackPaint);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r2),
        -pi / 2,
        (metrics.ramUsagePercent / 100.0) * 2 * pi,
        false,
        Paint()
          ..color = const Color(0xFF30D158)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Ring 3: Network / Battery (Blue/Yellow)
    final r3 = r2 - spacing;
    if (r3 > 0) {
      canvas.drawCircle(center, r3, trackPaint);
      final pct = metrics.isOffline
          ? 0.0
          : (metrics.downloadSpeedMbps / 150.0).clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r3),
        -pi / 2,
        pct * 2 * pi,
        false,
        Paint()
          ..color = metrics.isOffline
              ? const Color(0xFF3A3A3C)
              : const Color(0xFF0A84FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ObsidianPainter oldDelegate) => true;
}
