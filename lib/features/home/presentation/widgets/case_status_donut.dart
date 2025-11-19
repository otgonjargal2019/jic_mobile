import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jic_mob/core/models/dashboard/dashboard_data.dart';

class CaseStatusDonut extends StatelessWidget {
  final DashboardCaseSummary summary;
  final Color openColor;
  final Color onHoldColor;
  final Color closedColor;

  static const double _strokeWidth = 15;

  const CaseStatusDonut({
    super.key,
    required this.summary,
    required this.openColor,
    required this.onHoldColor,
    required this.closedColor,
  });

  @override
  Widget build(BuildContext context) {
    final segments = [
      _DonutSegment(value: summary.open.toDouble(), color: openColor),
      _DonutSegment(value: summary.onHold.toDouble(), color: onHoldColor),
      _DonutSegment(value: summary.closed.toDouble(), color: closedColor),
    ];

    final total = summary.total;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 104,
          height: 104,
          child: CustomPaint(
            painter: _DonutPainter(
              segments: segments,
              strokeWidth: _strokeWidth,
              backgroundColor: const Color(0xFFEAECEE),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF363249),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '건',
                style: TextStyle(color: Color(0xFF757380), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double strokeWidth;
  final Color backgroundColor;

  const _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final paintBackground = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, paintBackground);

    final total = segments.fold<double>(0, (sum, seg) => sum + seg.value);
    if (total <= 0) {
      return;
    }

    double startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweepAngle = (segment.value / total) * 2 * math.pi;
      final paintSegment = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paintSegment,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].value != segments[i].value ||
          oldDelegate.segments[i].color != segments[i].color) {
        return true;
      }
    }
    return false;
  }
}
