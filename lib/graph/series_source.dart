import 'dart:math';

import 'package:math_parser/math_parser.dart';


class SeriesSource {
  SeriesSource({
    required this.function,
    required this.from,
    required this.to,
    required this.step,
  });

  final String function;
  final double from;
  final double to;
  final double step;

  late final parsedFunction = MathNodeExpression.fromString(function);

  List<Point<double>> discretize() => [
    for (var x = from; x <= to; x += step)
      Point(
        x,
        parsedFunction.calc(MathVariableValues.x(x)).toDouble(),
      ),
    ];
}
