import 'dart:async';
import 'dart:collection';
import 'package:fractal/fractal.dart';

mixin MF<T> on FlowF<T> {
  var map = <Object, T>{};
  final requests = HashMap<Object, Completer<T>>();

  @override
  List<T> get list => map.values.toList();

  Future<T> request(Object key) async {
    if (map.containsKey(key)) {
      return map[key]!;
    }
    if (requests.containsKey(key)) {
      return requests[key]!.future;
    }

    final comp = Completer<T>();
    requests[key] = comp;

    return comp.future;
  }

  bool complete(Object key, T value) {
    map[key] = value;
    print('putf: $key');
    notify(value);
    final rq = requests[key];
    if (rq == null) return true;
    requests.remove(key);
    rq.complete(value);

    return true;
  }

  Iterable<T> get values => map.values;

  operator []=(Object key, T val) {
    if (!map.containsKey(key)) {
      complete(key, val);
    }
  }

  T? operator [](Object key) {
    return map[key]; // ??= word.frac() ?? Frac('');
  }

  discover(Object key) {}

  bool containsKey(Object key) => map.containsKey(key);

  T? remove(Object key) => map.remove(key);
}

class MapF<T extends Fractal> with FlowF<T>, MF<T> {
  @override
  notify(T fractal) {
    if (fractal.state == StateF.removed) {
      cleanUp();
    }
    super.notify(fractal);
  }

  @override
  input(T f) {
    complete(f.id, f);
  }

  cleanUp() {
    map.removeWhere((key, f) => f.state == StateF.removed);
  }

  @override
  bool complete(Object key, T event) {
    if (event.state == StateF.removed) {
      map.remove(key);
    } else {
      super.complete(key, event);
    }

    if (event.state != StateF.removed) {
      event.notifyListeners();
    }

    return true;
  }
}
