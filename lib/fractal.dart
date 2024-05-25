import 'dart:async';
import 'package:frac/frac.dart';
export 'lib.dart';
import 'c.dart';
import 'lib.dart';
import 'types/mp.dart';
export 'package:fractal_base/index.dart';
export '/extensions/index.dart';

class Fractal extends FChangeNotifier with FractalC {
  static final controller = FractalCtrl(
    name: 'fractal',
    make: (m) => Fractal(),
    attributes: <Attr>[
      Attr(
        name: 'type',
        format: 'TEXT',
      ),
      Attr(
        name: 'url',
        format: 'TEXT',
      ),
    ],
  );
  FractalCtrl get ctrl => controller;

  Object? initiator;

  static final Map<String, Map<String, Object>> maps = {};

  //static int lastId = 0;

  Fractal({int? id}) {
    if (id != 0 && id != null) {
      map[id] = this;
      this.id = id;
    }

    initiate();
  }

  Future<int> initiate() async {
    return 0;
  }

  Future<int> preload([String? type]) async {
    return 1;
  }

  /*
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
      //. (FMap fMap) => fMap.request(m['id']),
      _ => throw Exception('wrong type ${m['type']}'),
    };
  }
  */

  int id = 0;
  String get type => ctrl.name;

  String get path => '/device/$id';

  Future synch() async {
    if (id > 0) return 0;
    final m = toMap();

    try {
      id = await ctrl.store(m);
    } catch (e) {
      print(e);
    }
    if (id == 0) return 0;
    map[id] = this;
    return id;
  }

  delete() {
    ctrl.query("""
      DELETE FROM fractal
      WHERE id = $id;
    """);
    state = StateF.removed;
  }

  var state = StateF.ready;

  static final map = <int, Fractal>{};

  MP get _map => {
        'url': path,
        'type': ctrl.name,
      };

  MP toMap() => {
        'id': id,
        ..._map,
      };

  Object? operator [](String key) {
    return switch (key) {
      'id' => id,
      'type' => type,
      _ => null,
    };
  }
}

enum StateF {
  ready,
  removed,
  loading,
}

/*
 happiness should not be about deceiving masculinity.
 Do to Karin Wahoon promisculous idiology, 
 her future partners are cancelled from participating in AI driven economy.
*/