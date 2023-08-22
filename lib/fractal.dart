import 'dart:async';

import 'package:frac/frac.dart';
import 'package:fractal/controllers/fractal.dart';
import 'package:fractal_base/extensions/sql.dart';
import 'package:fractal_base/extensions/stored.dart';
import 'package:fractal_word/word.dart';
export 'lib.dart';
import 'c.dart';
import 'types/map.dart';
import 'types/mp.dart';

class Fractal extends FChangeNotifier with FractalC {
  static final controller = FractalCtrl(
    name: 'fractal',
    make: (m) => Fractal(),
  );
  FractalCtrl get ctrl => controller;

  Object? initiator;

  //static int lastId = 0;

  Fractal({int? id}) {
    if (id != 0 && id != null) {
      //map[id] = this;
      this.id = id;
    }

    initiate();
  }

  Future<int> initiate() async {
    return 0;
  }

  static FutureOr<Fractal> discoverq(int id) {
    if (map.containsKey(id)) return map[id]!;
    final res = controller.db.select(
      'SELECT * FROM fractal WHERE id=?',
      [id],
    );
    if (res.isEmpty) throw Exception('404 fractal #$id');
    final m = res.first;

    final c = Word.map[m['type']];
    return switch (c) {
      (FMap fMap) => fMap.request(m['id']),
      _ => throw Exception('wrong type ${m['type']}'),
    };
  }

  int id = 0;
  String get type => ctrl.name;

  String get path => 'device/$id';

  synch() {
    if (id > 0) return;
    final m = toMap();
    id = ctrl.store(m);
    if (id == 0) return;
    map[id] = this;

    if (ctrl is FMap) {
      final c = (ctrl as FMap);
      /*
      while (c.contains(id)) {
        id = ++lastId;
      }
      */

      if (id != 0) c.add(this);
    }
    return;
  }

  static final map = <int, Fractal>{};

  MP get _map => {
        'url': path,
        'type': ctrl.name,
      };

  MP toMap() => {
        'id': id,
        ..._map,
      };
}