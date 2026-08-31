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
    final maxRadius = min(size.width, size.height) / 2;

    // Glowing Core Reactor
    final corePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius * 0.75, corePaint);

    // Inner rotating blades
    final bladePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.03).clamp(1.5, 3.5);

    int blades = 8;
    for (int i = 0; i < blades; i++) {
      double angle = (i * (2 * pi / blades)) + (animationValue * 2 * pi);
      double innerR = maxRadius * 0.35;
      double outerR = maxRadius * 0.70;

      canvas.drawLine(
        Offset(
            center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
        Offset(
            center.dx + outerR * cos(angle), center.dy + outerR * sin(angle)),
        bladePaint,
      );
    }

    // Outer containment ring
    final outerRing = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.05).clamp(2.0, 5.0);

    canvas.drawCircle(center, maxRadius * 0.85, outerRing);

    // Activity arc
    final energyArc = Paint()
      ..color = const Color(0xFFFF9100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (maxRadius * 0.06).clamp(2.5, 6.0)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius * 0.92),
      0,
      (metrics.cpuUsage / 100.0) * 2 * pi,
      false,
      energyArc,
    );
  }

  @override
  bool shouldRepaint(covariant ReactorPainter oldDelegate) => true;
}
