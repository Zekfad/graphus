import 'dart:math';
import 'package:flutter/material.dart';

import 'graph_data.dart';
import 'linear_scale.dart';
import 'region.dart';
import 'scale.dart';
import 'series.dart';


enum RulerMode {
  left,
  right,
  bottom;
}

class GraphPainter extends CustomPainter {
  GraphPainter(this.data);

  GraphData data;

  static const textStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
  );

  final stroke = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final center = size.center(Offset.zero);

    if (!data.validate()) {
      drawText(canvas, 'Invalid config', center);
      canvas.restore();
      return;
    }

    final region = Region(
      size: const EdgeInsets.all(50.0).deflateSize(size),
      min: data.min,
      max: data.max,
    );


    final regionRect = Rect.fromCenter(
      center: center,
      width: region.size.width,
      height: region.size.height,
    );

    canvas.drawRect(
      regionRect,
      stroke,
    );

    drawText(canvas, 'X:', regionRect.bottomLeft + const Offset(-20, 5));
    drawRuler(
      canvas,
      regionRect: regionRect,
      scale: LinearScale(region.min, region.max),
      mode: RulerMode.bottom,
    );

    if (data.leftScale != null)
      drawRuler(
        canvas,
        regionRect: regionRect,
        scale: data.scales[data.leftScale!],
        mode: RulerMode.left,
      );

    if (data.rightScale != null)
      drawRuler(
        canvas,
        regionRect: regionRect,
        scale: data.scales[data.rightScale!],
        mode: RulerMode.right,
      );
    // drawText(canvas, '${region.max}', regionRect.bottomRight + const Offset(-5, 5));


    for (final series in data.series) {
      drawSeries(canvas, series, data.scales[series.scaleIndex], region, regionRect);
    }

    canvas.restore();
  }

  void drawText(Canvas canvas, String text, Offset location) {
    (TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, location);
  }

  void drawRuler(Canvas canvas, {
    required Rect regionRect,
    required Scale scale,
    RulerMode mode = RulerMode.bottom,
    int segments = 10,
  }) {
    final tickSize = (mode == RulerMode.bottom
      ? regionRect.width
      : regionRect.height) / segments;

    final tickHalfSize = mode == RulerMode.bottom
      ? const Offset(0, 5)
      : const Offset(5, 0);

    final textOffset = mode == RulerMode.bottom
      ? const Offset(-5, 5)
      : mode == RulerMode.left
        ? const Offset(-45, -6)
        : const Offset(10, -6);

    for (var i = 0; i <= segments; i++) {
      final value = scale.min + scale.range * i / segments;
      final tickOffset = regionRect.bottomLeft + (mode == RulerMode.bottom
        ? Offset(tickSize * i, 0)
        : Offset(mode == RulerMode.left ? 0 : regionRect.width, -tickSize * i));
      canvas.drawLine(
        tickOffset - tickHalfSize,
        tickOffset + tickHalfSize,
        stroke,
      );
      drawText(
        canvas,
        value.toStringAsFixed(2),
        tickOffset + textOffset,
      );

    } 
  }

  void drawSeries(Canvas canvas, Series series, Scale scale, Region region, Rect regionRect) {
    final points = region.getRegionPoints(series.points, 2).map(
      (point) => scale.scalePoint(point, region),
    );

    final path = series.smooth
      ? getSeriesSmoothPath(points, series.smoothFactor)
      : getSeriesSharpPath(points);
    canvas
      ..save()
      ..clipRect(regionRect)
      ..translate(regionRect.left, regionRect.top)
      ..drawPath(path, series.paint)
      ..restore();
  }

  Path getSeriesSharpPath(Iterable<Offset> points) {
    final iterator = points.iterator;

    if (!iterator.moveNext())
      throw Exception('Not enough points to draw a path');

    final path = Path()
      ..moveTo(iterator.current.dx, iterator.current.dy);

    while (iterator.moveNext())
      path.lineTo(iterator.current.dx, iterator.current.dy);

    return path;
  }

  /// Based on http://scaledinnovation.com/analytics/splines/aboutSplines.html
  Path getSeriesSmoothPath(Iterable<Offset> _points, [double t = 0.5]) {
    final points = _points.toList(growable: false);
    final n = points.length;
    if (n < 2)
      throw Exception('Not enough points to draw a path');

    final path = Path();
    final controlPoints = <Offset>[];

    for (var i = 0; i < n - 2; i++) {
      final (cp1, cp2) = getControlPoints(points[i], points[i + 1], points[i + 2], t);
      controlPoints.addAll([cp1, cp2]);
    }

    // for (var i = 1; i < n - 2; i++) {
    //   path
    //     ..moveTo(points[i].dx, points[i].dy)
    //     ..cubicTo(
    //       controlPoints[i*2 - 1].dx, controlPoints[i*2 - 1].dy, 
    //       controlPoints[i*2].dx, controlPoints[i*2].dy,
    //       points[i + 1].dx, points[i + 1].dy,
    //     );
    // }

    // // For open curves the first and last arcs are simple quadratics.
    // path
    //   ..moveTo(points.first.dx, points.first.dy)
    //   ..quadraticBezierTo(
    //     controlPoints.first.dx, controlPoints.first.dy,
    //     points[1].dx, points[1].dy,
    //   )
    //   ..moveTo(points[n - 2].dx, points[n - 2].dy)
    //   ..quadraticBezierTo(
    //     controlPoints.last.dx, controlPoints.last.dy,
    //     points.last.dx, points.last.dy,
    //   );

    // For open curves the first and last arcs are simple quadratics.

    path
      ..moveTo(points.first.dx, points.first.dy)
      ..quadraticBezierTo(
        controlPoints.first.dx, controlPoints.first.dy,
        points[1].dx, points[1].dy,
      );

    for (var i = 1; i < n - 2; i++)
      path.cubicTo(
        controlPoints[i*2 - 1].dx, controlPoints[i*2 - 1].dy, 
        controlPoints[i*2].dx, controlPoints[i*2].dy,
        points[i + 1].dx, points[i + 1].dy,
      );

    path.quadraticBezierTo(
      controlPoints.last.dx, controlPoints.last.dy,
      points.last.dx, points.last.dy,
    );

    return path;
  }

  /// [p0], [p1] are the coordinates of the end (knot) points of this segment
  /// [p2] is the next knot -- not connected here but needed to calculate cp2
  /// cp1 is the control point calculated here, from [p1] back toward [p0].
  /// cp2 is the next control point, calculated here and returned to become the 
  /// next segment's cp1
  /// [t] is the 'tension' which controls how far the control points spread.
  (Offset, Offset) getControlPoints(Offset p0, Offset p1, Offset p2, double t){
    //  Scaling factors: distances from this knot to the previous and following knots.
    final d01 = sqrt(pow(p1.dx - p0.dx, 2) + pow(p1.dy - p0.dy, 2));
    final d12 = sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
  
    final fa = t * d01 / (d01 + d12);
    final fb = t - fa;
  
    final cp1 = Offset(
      p1.dx + fa * (p0.dx - p2.dx),
      p1.dy + fa * (p0.dy - p2.dy),
    );

    final cp2 = Offset(
      p1.dx - fb * (p0.dx - p2.dx),
      p1.dy - fb * (p0.dy - p2.dy),
    );

    return (cp1, cp2);
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) => true;
}
