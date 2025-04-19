import 'dart:async';
import '../index.dart';
import '../mixins/mpf.dart';

class Fractal extends FChangeNotifier
    with FractalC, Axi, MPF
    implements FilterableF, MP {
  static final idAttr = Attr(
    name: 'id',
    format: FormatF.integer,
    isImmutable: true,
    skipCreate: true,
    isIndex: true,
  );

  static final controller = FractalCtrl(
    name: 'fractal',
    make: (m) => Fractal(),
    attributes: <Attr>[
      idAttr,
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
      storage[id] = this;
      this.id = id;
    }
  }

  Fractal.fromMap(MP d)
      : kind = FKind.values[d['kind'] ?? 0],
        storedAt = d['stored_at'] ?? 0 {
    if (d['id'] case int id) {
      storage[id] = this;
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

  String get key => '#$id';

  int id = 0;
  String get type => ctrl.name;

  String get path => '/device/$id';
  int storedAt = 0;

  Future<int>? storing;
  Future<int> store([MP? m]) async {
    if (kind == FKind.tmp) return 0;
    if (storedAt > 0) return this.id;
    if (storing != null) return storing!;
    MP mp = {
      ...toMap(),
      ...?m,
      'stored_at': unixSeconds,
    };
    if (mp['id'] case int id) return id;

    //mp.remove('id');
    final id = mp['id'] = ++db.lastId;
    final isOk = await ctrl.store(mp);
    if (!isOk) return 0;
    this.id = id;
    storage[id] = this;
    return id;
  }

  spread(thing) {}

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

  static final storage = MapF<Fractal>();

  resolve(String key) {
    if (this[key] case Object val) {
      return val;
    }
  }

  @override
  Object? operator [](Object? key) {
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
