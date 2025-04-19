import 'package:fractal/models/fractal.dart';
import 'package:fractal/index.dart';

class PulseF with FlowF, MF implements FilterableF {
  Fractal by;
  final passed = <Fractal>[];
  final outputBy = <Fractal, MP>{};
  PulseF({
    Map<Object, dynamic>? map,
    required this.by,
  }) {
    if (map != null) super.map = map;
  }
}

class SparkF {
  PulseF pulse;
  MP map;

  SparkF re(MP mp) => SparkF(
        pulse: pulse,
        map: mp,
      );

  SparkF({
    required this.pulse,
    required this.map,
  });

  operator []=(String key, val) {
    if (!map.containsKey(key)) {
      map[key] = val;
    }
  }

  operator [](key) {
    return map[key]; // ??= word.frac() ?? Frac('');
  }
}
