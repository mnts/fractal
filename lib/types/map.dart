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

  T put(MP item) {
    final pass = item['pass'];
    final fractal = make(item);
    add(fractal);
    return fractal;
  }

  void complete(int id) {
    final rqs = requests[id];
    if (rqs == null) return;
    for (final rq in rqs) {
      rq.complete(map[id]);
    }
    rqs.clear();
  }

  Iterable<T> preload(Iterable json) {
    dontNotify = true;
    final re = <T>[];
    for (MP item in json) {
      if (item['id'] is int && !contains(item['id'])) {
        final fractal = put(item);
        re.add(fractal);
      }
    }
    dontNotify = false;
    return re;
  }

  bool dontNotify = false;

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

  T? discover(int id) {
    final res = db.select('SELECT * FROM $name WHERE id=?', [id]);
    if (res.isEmpty) return null;
    print(res);
    return put(res.first);
  }

  Iterable<T> get values => map.values;
  Iterable<int> get keys => map.keys;

  remove(int id) {
    map.remove(id);
  }

  int add(T fractal) {
    if (!contains(fractal.id)) {
      this[fractal.id] = fractal;
    } /* else {
      throw Exception(
        '${fractal.id} already associated to $name',
      );
    }*/
    //fractal.synched = true;

    print('Add #${fractal.id} ${fractal.runtimeType}');
    return fractal.id;
  }
}
