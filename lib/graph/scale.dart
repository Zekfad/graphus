import 'dart:math';
import 'dart:ui';

import 'region.dart';


abstract class Scale {
  const Scale(this.min, this.max) :
    assert(max > min, 'max should be greater than min'),
    range = max - min;

  final double min;
  final double max;
  final double range;

  /// Converts [y] of a point to [0, 1] range.
  double getScaledY(double y);

  /// Scales point related to region.
  Offset scalePoint(Point<double> point, Region region) =>
    Offset(
      (point.x - region.min) * region.size.width / region.range,
      (1 - getScaledY(point.y)) * region.size.height,
    );
}
