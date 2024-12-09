import 'dart:async';
import 'package:frac/index.dart';
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

  /*
  final refs = <String, T>{};
  static Fractal? refer(String ref) {
    for (var ctrl in EventFractal.controller.controllers) {
      return ctrl.refs[];
    }
  }
  */

  final Word extend;

  final List<Attr> attributes;
  late final Map<String, Attr> allAttributes = Map.fromEntries([
    ...attributes,
    for (var ctrl in controllers) ...ctrl.attributes,
  ].map((attr) => MapEntry(attr.name, attr)));

  final listeners = <Function(T)>[];

  final selector = SqlContext();
  late TableF table;

  FutureOr<void> init() async {
    //print('$name initiated');
    //make({});

    //map.values.where((ctrl) => ctrl is this.runtimeType);

    table = await initSql();
    await initIndexes();
    return;
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
