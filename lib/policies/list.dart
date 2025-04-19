import '../models/fractal.dart';

mixin ListPolicy implements Fractal {
  final list = <Fractal>[];
  add() {}
}
