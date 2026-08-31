import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hud_metrics.dart';

class CyberpunkPainter extends CustomPainter {
  final HudMetrics metrics;
  final double animationValue;

  CyberpunkPainter({required this.metrics, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    // Glowing Outer Ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFF0055).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.04).clamp(1.5, 4.0);
    canvas.drawCircle(center, maxRadius * 0.9, ringPaint);

    // Dynamic Arc based on CPU
    final cpuArcPaint = Paint()
      ..color = const Color(0xFFFF0055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.08).clamp(3.0, 8.0)
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (metrics.cpuUsage / 100.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.9),
      -pi / 2,
      sweepAngle,
      false,
      cpuArcPaint,
    );

    // RAM Arc
    final ramArcPaint = Paint()
      ..color = const Color(0xFF00FFCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.08).clamp(3.0, 8.0)
      ..strokeCap = StrokeCap.round;

    double ramSweep = (metrics.ramUsagePercent / 100.0) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.75),
      -pi / 2,
      ramSweep,
      false,
      ramArcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CyberpunkPainter oldDelegate) => true;
}
