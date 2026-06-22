import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.points,
    this.lineColor = const Color(0xFF0A84FF),
  });

  final List<double> points;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniLinePainter(points: points, lineColor: lineColor),
      size: Size.infinite,
    );
  }
}

class _MiniLinePainter extends CustomPainter {
  _MiniLinePainter({required this.points, required this.lineColor});

  final List<double> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final minValue = points.reduce((a, b) => a < b ? a : b);
    final maxValue = points.reduce((a, b) => a > b ? a : b);
    final range =
        (maxValue - minValue).abs() < 0.0001 ? 1.0 : maxValue - minValue;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = index * (size.width / (points.length - 1));
      final normalized = (points[index] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    for (var index = 0; index < points.length; index++) {
      final x = index * (size.width / (points.length - 1));
      final normalized = (points[index] - minValue) / range;
      final y = size.height - (normalized * size.height);
      canvas.drawCircle(
        Offset(x, y),
        3.2,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
