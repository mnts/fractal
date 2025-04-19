import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fractal/index.dart';

mixin FilterF<T extends Fractal> on Fractal, FlowF<T>, Hashed {
  FlowF? get source => EventFractal.controller;
  Map<String, dynamic> get filter => {
        'to': hash,
        /*
        'type': {
          'nin': ['meeting']
        }
        */
      };

  static const defaultOrder = {'created_at': true};
  MP get order => defaultOrder;

  int get limit => 0;
  //bool get includeSubTypes => true;
  bool get onlyLocal => false;

  final loaded = Completer<bool>();
  Future<bool> get whenLoaded => loaded.future;
  final subscribed = Completer<bool>();
  Future<bool> get whenSubscribed => subscribed.future;

  int latestSynch = 0;

  static Function(MP)? discovery;

  bool matchSource(Fractal f) {
    if (source case EventsCtrl ctrl) {
      //if (!includeSubTypes && f.type != ctrl.name) return false;
      if (!(f.type == ctrl.name || ctrl.top.any((c) => c.name == f.type))) {
        return false;
      }
    }
    if (source case CatalogFractal c) {
      return c.matchSource(f);
    }
    return true;
  }

  T? byId(int id) {
    try {
      return list.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    list.clear();
    if (source case EventsCtrl evCtrl) {
      evCtrl.list.forEach(input);
      evCtrl.listen(input);
      //if (includeSubTypes) {
      for (var c in evCtrl.top) {
        c.list.forEach(input);
        c.listen(input);
      }
      //}
      notifyListeners();
    }

    await query();
    return;
  }

  @override
  bool input(Fractal f) {
    if (f is T && matchSource(f) && f.match(filter)) {
      if (f.state == StateF.removed) {
        list.remove(f);
        notifyListeners();
        return false;
      }

      if (list.contains(f)) return true;

      final o = order.entries.first;

      if (f case EventFractal ev when ev.syncAt > latestSynch) {
        latestSynch = ev.syncAt;
      }

      list.add(f);

      if (o.key == 'created_at') {
        list.sort((a, b) {
          var ac = a.id;
          var bc = a.id;
          if (a case EventFractal ef) {
            ac = ef.createdAt;
          }
          if (b case EventFractal ef) {
            bc = ef.createdAt;
          }
          return ac.compareTo(bc);
        });
      }

      notify(f);

      return true;
    }
    return false;
  }

  @override
  dispose() {
    //sub.unListen(receive);
    if (source case EventsCtrl evCtrl) {
      evCtrl.unListen(input);
      //if (includeSubTypes) {
      for (var c in evCtrl.top) {
        c.unListen(input);
      }
      super.dispose();
      //}
    }
  }

  Future<void> query() async {
    //List<MP> r = [];
    if (filter.isEmpty) return;
    if (source case EventsCtrl ctrl) {
      await ctrl.find(
        {...filter},
        limit: limit,
        order: order,
      );
    }

    if (!loaded.isCompleted) {
      loaded.complete(true);
    }
    return;
  }

  /*
  void _subscribe() async {
    await initiate();
    look(client);
    sink({
      'cmd': 'subscribed',
      'hash': hash,
      'list': list.whereType<EventFractal>().map((f) => f.hash).toList(),
    });
  }
  */

  @override
  List<T> listen(fn) {
    if (this case Fractal f) f.initiate();
    return super.listen(fn);
  }

  static final timerC = TimedF();
  static Map<String, List<int>> collecting = {};
  static final comp = <int, Completer<Fractal?>>{};
  static List<Future<Fractal?>> collect(Iterable<Map> frags) {
    //Map<String, List<int>> collecting = {};
    final fus = <Future<Fractal?>>[];
    var need = 0;
    for (var m in frags) {
      final id = m['id'];

      if (Fractal.storage[id] case Fractal f) {
        fus.add(Future.value(f));
        continue;
      }

      var c = comp[id];
      if (c == null) {
        comp[id] = c = Completer();
        final type = m['type'];
        final ids = collecting[type] ??= [];
        if (!ids.contains(id)) {
          ids.add(id);
          need++;
        }
      }

      fus.add(c.future);
    }

    if (need > 0) timerC.hold(_collect, 30);

    /*
    for (var item in frags) {
      await Fractal.storage.request(item['id']);
    }
    */

    return fus;
  }

  static void _collect() {
    /// fractals are stored in the cache and the corresponding `Completer`s are
    final entries = [...collecting.entries];

    for (var en in entries) {
      final ctrl = FractalCtrl.map[en.key] as EventsCtrl;
      if (en.value.isEmpty) continue;
      final val = [...en.value];
      print('collect $val');
      en.value.clear();
      ctrl.select(
        where: {'id': val},
      ).then((res) {
        for (MP item in res.reversed) {
          //final type = item['type'];
          final id = item['id'];

          final c = comp[id]!;
          if (c.isCompleted) continue;
          ctrl.put(MakeF(item)).then((f) {
            if (!c.isCompleted) c.complete(f);
          }, onError: (e) {
            print('failed: $e');
            if (!c.isCompleted) c.complete(null);
          });
          //fractals.add(f);
        }
      });
    }
  }
}
