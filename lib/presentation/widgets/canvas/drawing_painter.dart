import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

class ActiveDrawingPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final Color color;
  final double strokeWidth;

  ActiveDrawingPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final inputPoints = points
        .map((p) => PointVector(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
              (p['pressure'] as num?)?.toDouble() ?? 0.5,
            ))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: strokeWidth * 3,
        thinning: 0.5,
        smoothing: 0.5,
        streamline: 0.5,
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length < 2) {
      canvas.drawCircle(
        outlinePoints.first,
        strokeWidth / 2,
        Paint()..color = color,
      );
      return;
    }

    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 1; i < outlinePoints.length - 1; i++) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant ActiveDrawingPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}

class DrawingElementPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final Color color;
  final double strokeWidth;

  DrawingElementPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final inputPoints = points
        .map((p) => PointVector(
              (p['x'] as num).toDouble(),
              (p['y'] as num).toDouble(),
              (p['pressure'] as num?)?.toDouble() ?? 0.5,
            ))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: strokeWidth * 3,
        thinning: 0.5,
        smoothing: 0.5,
        streamline: 0.5,
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length < 2) {
      canvas.drawCircle(
        outlinePoints.first,
        strokeWidth / 2,
        Paint()..color = color,
      );
      return;
    }

    path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (int i = 1; i < outlinePoints.length - 1; i++) {
      final p0 = outlinePoints[i];
      final p1 = outlinePoints[i + 1];
      path.quadraticBezierTo(
        p0.dx,
        p0.dy,
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant DrawingElementPainter oldDelegate) => true;
}
