import 'dart:math';
import 'dart:ui';

import 'series_source.dart';


class Series {
  const Series({
    required this.points,
    required this.paint,
    required this.scaleIndex,
    this.source,
    this.smoothFactor = 0.5,
  });

  final List<Point<double>> points;
  final Paint paint;
  final int scaleIndex;
  final double smoothFactor;
  final SeriesSource? source;
  bool get smooth => smoothFactor != 0;
}
