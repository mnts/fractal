/*
import 'dart:async';
import 'dart:collection';
import '../fractal.dart';

mixin FMap<T extends Fractal> on FractalCtrl<T> {
  final map = HashMap<int, T>();

  @override
  String get name => super.name;

  operator []=(int key, T val) {
    map[key] = val;
    notify(val);
    complete(key);
  }

  T? operator [](int key) {
    return map[key]; // ??= word.frac() ?? Frac('');
  }

  bool contains(int id) => map.containsKey(id);

  void complete(int id) {
    final rqs = requests[id];
    if (rqs == null) return;
    for (final rq in rqs) {
      rq.complete(map[id]);
    }
    rqs.clear();
  }

  listen(Function(T) fn) {
    listeners.add(fn);
  }

  unListen(Function(T) fn) {
    listeners.remove(fn);
  }

  notify(T fractal) {
    for (final fn in listeners) {
      fn(fractal);
    }
  }

  final requests = HashMap<int, List<Completer<T>>>();
  Future<T> request(int id) {
    final comp = Completer<T>();
    if (contains(id)) {
      comp.complete(map[id]!);
    } else {
      if (requests.containsKey(id)) {
        requests[id]!.add(comp);
      } else {
        requests[id] = [comp];
      }
      discover(id);
    }
    return comp.future;
  }

  Iterable<T> get values => map.values;
  Iterable<int> get keys => map.keys;

  remove(int id) {
    map.remove(id);
  }
}
*/