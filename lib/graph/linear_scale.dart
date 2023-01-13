import 'scale.dart';


class LinearScale extends Scale {
  const LinearScale(super.min, super.max);

  @override
  double getScaledY(double y) =>
    (y - min) / range;
}
