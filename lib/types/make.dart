import '../lib.dart';

class MakeF {
  MP map = {};
  final Fractal? by;

  factory MakeF.init(d) {
    return switch (d) {
      MakeF mk => mk,
      MP m => MakeF(m),
      Map m => MakeF({...m}),
      _ => throw 'You put wrong type - $d',
    };
  }

  MakeF(
    MP m, {
    this.by,
  }) {
    map = {...m};
  }
}
