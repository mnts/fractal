import 'dart:async';
export 'lib.dart';
import 'lib.dart';
export '/enums/index.dart';
export 'package:fractal_base/index.dart';
export '/extensions/index.dart';

class Fractal extends FChangeNotifier
    with FractalC, Axi
    implements FilterableF {
  static final controller = FractalCtrl(
    name: 'fractal',
    make: (m) => Fractal(),
    attributes: <Attr>[
      Attr(
        name: 'id',
        format: FormatF.integer,
        isImmutable: true,
        skipCreate: true,
        isIndex: true,
      ),
      Attr(
        name: 'stored_at',
        format: FormatF.integer,
        isIndex: true,
      ),
      Attr(
        name: 'type',
        format: FormatF.text,
        isIndex: true,
      ),
      Attr(
        name: 'kind',
        format: FormatF.integer,
        def: '0',
      ),
      Attr(
        name: 'url',
        format: FormatF.text,
      ),
    ],
  );
  FractalCtrl get ctrl => controller;

  Object? initiator;

  static final Map<String, Map<String, Object>> maps = {};

  //static int lastId = 0;

  final FKind kind;

  Fractal({
    int? id,
    this.kind = FKind.basic,
  }) {
    if (id != 0 && id != null) {
      map[id] = this;
      this.id = id;
    }
  }

  Fractal.fromMap(MP d)
      : kind = FKind.values[d['kind'] ?? 0],
        storedAt = d['stored_at'] ?? 0 {
    if (d['id'] case int id) {
      map[id] = this;
      this.id = id;
    }
  }

  Future<bool> initiate() async {
    return true;
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
  int storedAt = 0;

  Future<int>? storing;
  Future<int> store([MP? m]) async {
    if (kind == FKind.tmp) return 0;
    if (storedAt > 0) return id;
    if (storing != null) return storing!;
    MP mp = {
      ...toMap(),
      ...?m,
      'stored_at': unixSeconds,
    };
    mp.remove('id');
    storing = ctrl.store(mp);
    id = await storing!;
    if (id == 0) return 0;
    map[id] = this;
    return id;
  }

  MP toMap() => {
        'type': type,
        'kind': kind.index,
      };

  Future synch() async {
    if (id > 0) return 0;

    try {
      await store();
    } catch (e) {
      print(e);
    }
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

  static final map = MapF<Fractal>();

  resolve(String key) {
    if (this[key] case Object val) {
      return val;
    }
  }

  Object? operator [](String key) {
    return switch (key) {
      'id' => id,
      'type' => type,
      'kind' => kind.index,
      _ => null,
    };
  }

  String represent(String key) => '${this[key] ?? ''}';
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
