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
    final cyanPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final magentaPaint = Paint()
      ..color = const Color(0xFFFF007A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Grid Background
    final gridPaint = Paint()
      ..color = const Color(0xFF142442).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Outer Target Rings
    canvas.drawCircle(center, 140, cyanPaint..strokeWidth = 1.5);
    canvas.drawCircle(center, 120, magentaPaint..strokeWidth = 1.0);

    // Rotating Arcs
    final arcRect = Rect.fromCircle(center: center, radius: 130);
    canvas.drawArc(arcRect, animationValue * 2 * pi, pi / 2, false, cyanPaint..strokeWidth = 4.0);
    canvas.drawArc(arcRect, -animationValue * 2 * pi + pi, pi / 3, false, magentaPaint..strokeWidth = 4.0);

    // Central CPU Load Arc
    final cpuAngle = (metrics.cpuUsage / 100.0) * 2 * pi;
    final cpuRect = Rect.fromCircle(center: center, radius: 90);
    canvas.drawArc(cpuRect, -pi / 2, cpuAngle, false, Paint()
      ..color = const Color(0xFF00FF9D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
    );

    // Dynamic Waveform across center
    final wavePaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double x = 20; x < size.width - 20; x += 5) {
      double relX = (x - size.width / 2) / 60;
      double y = center.dy + 180 + sin(relX * 4 + animationValue * 2 * pi) * (metrics.cpuUsage * 0.3);
      if (x == 20) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CyberpunkPainter oldDelegate) => true;
}
