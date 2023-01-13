import 'scale.dart';
import 'series.dart';


class GraphData {
  const GraphData({
    required this.series,
    required this.scales,
    required this.min,
    required this.max,
    this.leftScale,
    this.rightScale,
  }) :
    // assert(max > min, 'max should be greater than min'),
    // assert(scales.length > 0, 'at least 1 scale should be set'),
    range = max - min;

  final List<Series> series;
  final List<Scale> scales;
  final double min;
  final double max;
  final double range;
  final int? leftScale;
  final int? rightScale;

  GraphData copyWith({
    List<Series>? series,
    List<Scale>? scales,
    double? min,
    double? max,
    int? leftScale,
    int? rightScale,
  }) =>
    GraphData(
      series: series ?? this.series,
      scales: scales ?? this.scales,
      min: min ?? this.min,
      max: max ?? this.max,
      leftScale: leftScale ?? this.leftScale,
      rightScale: rightScale ?? this.rightScale,
    );

  bool validate() =>
    max > min &&
    scales.isNotEmpty &&
    (leftScale == null || (leftScale! >= 0 && scales.length > leftScale!)) &&
    (rightScale == null || (rightScale! >= 0 && scales.length > rightScale!)) &&
    series.every((series) => series.scaleIndex < scales.length);
}
