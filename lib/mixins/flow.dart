import 'package:fractal/index.dart';

abstract class SinkF {
  Future<MP> rx(MP);
  Future<bool> sink(d);
  pick(String h);
}

mixin FlowF<T> implements FListenable {
  List<T> list = [];
  final listeners = <Function(T)>[];

  T? get first {
    return (list.isEmpty) ? null : list.first;
  }

  final looking = <SinkF>[];
  void look(SinkF f) {
    if (looking.contains(f)) return;
    looking.add(f);
  }

  unLook(SinkF f) {
    looking.removeWhere((ff) => ff == f);
  }

  List<T> listen(Function(T) fn) {
    listeners.add(fn);
    return list;
  }

  void unListen(Function(T) fn) {
    listeners.removeWhere((f) => f == fn);
  }

  final listenersVoid = <Function()>[];
  @override
  void addListener(VoidCallback listener) {
    listenersVoid.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that the
  /// object notifies.
  @override
  void removeListener(VoidCallback listener) {
    listenersVoid.remove(listener);
  }

  input(T f) {
    if (list.contains(f)) return;
    list.add(f);
    notify(f);
  }

  notifyListeners() {
    for (final fn in listenersVoid) {
      fn();
    }
  }

  int get interest => listeners.length + listenersVoid.length + looking.length;
  bool get noInterest =>
      listeners.isEmpty && listenersVoid.isEmpty && looking.isEmpty;

  notify(T fractal) {
    for (final s in looking) {
      s.sink(fractal);
    }
    for (final fn in listeners) {
      fn(fractal);
    }
    for (final fn in listenersVoid) {
      fn();
    }
  }
}
