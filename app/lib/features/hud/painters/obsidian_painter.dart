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

    // Apple Style Concentric Clean Activity Rings
    final trackPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;

    // Ring 1: CPU
    const r1 = 120.0;
    canvas.drawCircle(center, r1, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r1),
      -pi / 2,
      (metrics.cpuUsage / 100.0) * 2 * pi,
      false,
      Paint()
        ..color = const Color(0xFFFF453A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round,
    );

    // Ring 2: RAM
    const r2 = 96.0;
    canvas.drawCircle(center, r2, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r2),
      -pi / 2,
      (metrics.ramUsagePercent / 100.0) * 2 * pi,
      false,
      Paint()
        ..color = const Color(0xFF30D158)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round,
    );

    // Ring 3: Network
    const r3 = 72.0;
    canvas.drawCircle(center, r3, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r3),
      -pi / 2,
      (metrics.downloadSpeedMbps / 200.0).clamp(0.0, 1.0) * 2 * pi,
      false,
      Paint()
        ..color = const Color(0xFF0A84FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant ObsidianPainter oldDelegate) => true;
}
