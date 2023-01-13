import 'dart:collection';
import 'dart:math';
import 'dart:ui';


class Region {
  const Region({
    required this.size,
    required this.min,
    required this.max,
  }) :
    assert(max > min, 'max should be greater than min'),
    range = max - min;

  final Size size;
  final double min;
  final double max;
  final double range;

  bool includesPoint(Point<double> point, [bool inclusive = true]) =>
    inclusive
      ? point.x >= min && point.x <= max
      : point.x > min && point.x < max;

  /// Returns points that are required to properly draw a region:
  /// * Points that inside the region
  /// * Edge [outerPoints] points from left and right
  List<Point<double>> getRegionPoints(List<Point<double>> points, [int outerPoints = 2]) {
    if (points.isEmpty)
      return [];

    final result = <Point<double>>[];
    final outerQueue = Queue<Point<double>>();

    final iterator = points.iterator;
    var left = true;

    while (iterator.moveNext()) {
      final current = iterator.current;
      final currentIn = includesPoint(current, false);

      if (!currentIn) {
        if (left) { // before first included point
          outerQueue.addLast(current);
          if (outerQueue.length > outerPoints)
            outerQueue.removeFirst();
        } else { // after last included point
          if (outerQueue.length == outerPoints)
            break;
          outerQueue.addLast(current);
        }
      } else {
        if (left) { // first included point
          left = false;
          result.addAll(outerQueue);
          outerQueue.clear();
        }
        result.add(current);
      }
    }

    // Add right remaining
    result.addAll(outerQueue);

    return result;
  }
}
