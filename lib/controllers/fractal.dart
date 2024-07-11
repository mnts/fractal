import 'dart:async';
import 'package:fractal_word/word.dart';
import '../fractal.dart';

class FractalCtrl<T extends Fractal> extends Word {
  FractalCtrl({
    this.extend = Word.god,
    String name = 'fractal',
    required this.make,
    required this.attributes,
  }) : super.id(name, ++Word.lastId) {
    _init();
    //print('$name ctrl defined for $T');
  }

  List<FractalCtrl> get controllers {
    final ctrls = <FractalCtrl>[this];

    while (ctrls.last.extend is FractalCtrl) {
      ctrls.add(ctrls.last.extend as FractalCtrl);
    }
    return ctrls.sublist(1, ctrls.length - 1);
  }

  final Word extend;

  final List<Attr> attributes;

  final listeners = <Function(T)>[];

  final selector = SqlContext();
  late TableF table;

  FutureOr<void> init() async {
    //print('$name initiated');
    //make({});

    //map.values.where((ctrl) => ctrl is this.runtimeType);

    table = await initSql();
    await initIndexes();
  }

  FutureOr<T> Function(dynamic) make;
  late T initial;
  //Type get fractalType => Fractal;

  static final map = <String, FractalCtrl>{};

  static Iterable<S> where<S extends FractalCtrl>() =>
      map.values.whereType<S>();

  final sub = <FractalCtrl>[];

  List<FractalCtrl> get top => [
        ...sub,
        for (final s in sub) ...s.top,
      ];

  _init() {
    map[name] = this;
  }
}
