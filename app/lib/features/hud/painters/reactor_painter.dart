import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hud_metrics.dart';

class ReactorPainter extends CustomPainter {
  final HudMetrics metrics;
  final double animationValue;

  ReactorPainter({required this.metrics, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Glowing Core Reactor
    final corePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 90, corePaint);

    // Inner rotating blades
    final bladePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    int blades = 8;
    for (int i = 0; i < blades; i++) {
      double angle = (i * (2 * pi / blades)) + (animationValue * 2 * pi);
      double innerR = 40.0;
      double outerR = 85.0;
      canvas.drawLine(
        Offset(center.dx + cos(angle) * innerR, center.dy + sin(angle) * innerR),
        Offset(center.dx + cos(angle) * outerR, center.dy + sin(angle) * outerR),
        bladePaint,
      );
    }

    // Outer Gauge with Orange Secondary Accent
    final orangePaint = Paint()
      ..color = const Color(0xFFFF9100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 120),
      pi / 4,
      (metrics.cpuUsage / 100.0) * (3 * pi / 2),
      false,
      orangePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ReactorPainter oldDelegate) => true;
}
