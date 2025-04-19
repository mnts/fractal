import 'dart:async';
import '../index.dart';

class EventsCtrl<T extends EventFractal> extends FractalCtrl<T> with FlowF<T> {
  EventsCtrl({
    super.name = 'event',
    required super.make,
    required super.extend,
    required super.attributes,
  }) {
    if (extend case FractalCtrl ext) ext.sub.add(this);
  }

  var transformers = <String, T Function(T, Rewritable)>{};

  /*
  //final map = MapF<T>();
  List<T> findt(MP m) {
    final list = <T>[...map.values];
    if (m case {'since': int time}) {
      time;
    }
    return list;
  }
  */

  List hashData(MP m) {
    final h = [m['kind'] ?? 0, name];
    final ctrls = [
      ...controllers.reversed.whereType<EventsCtrl>(),
      this,
    ];

    for (var ctrl in ctrls) {
      final imu = ctrl.immutableData(m);
      h.addAll(imu);
    }

    return h;
  }

  List<Object> immutableData(MP m) => [
        ...attributes
            .where((a) =>
                a.isImmutable &&
                !(a.name == 'created_at' && (m['kind'] ?? 0) > 0))
            .map(
              (a) => (switch (m[a.name]) {
                EventsCtrl c => c.name,
                EventFractal f => f.hash,
                Object o => o,
                null => '',
              }),
            ),
      ];

  bool dontNotify = false;

  void preload(Iterable json) {
    dontNotify = true;
    for (MP item in json) {
      if (item['id'] is int && !Fractal.storage.containsKey(item['id'])) {
        put(MakeF(item));
      }
    }
    dontNotify = false;
  }

  @override
  List<EventsCtrl> get top => super.top.map((c) => c as EventsCtrl).toList();

  Future<T> put(d) async {
    //final ctrl = FractalCtrl.map[item['name']] as EventsCtrl;
    final mk = MakeF.init(d);

    final attrs = allAttributes;
    await FData.require(mk, [
      ...attrs.values
          .where(
            (a) => a.format == FormatF.reference,
          )
          .map((a) => a.name)
    ]);

    if ((mk.map['hash'] ?? '') == '') {
      final hd = hashData(mk.map);
      mk.map['hash'] = Hashed.make(hd);
    }

    var evf = EventFractal.storage[mk.map['hash']] as T?;

    if (evf != null) return evf;

    if ([
          FKind.system.index,
          FKind.eternal.index,
          FKind.file.index,
        ].contains(mk.map['kind']) &&
        mk.map['stored_at'] == null) {
      final res = await select(
        where: {'hash': mk.map['hash']},
      );

      print('#${mk.map['hash']} res $res');
      res.firstOrNull?.forEach((k, v) {
        final attr = attrs[k];
        if (attr?.format != FormatF.reference && !mk.map.containsKey(k)) {
          mk.map[k] = v;
        }
      });
    }

    print('put ${mk.map}');

    return evf ?? make(mk.map);
  }

  Future<Iterable<Fractal>> find(
    MP filter, {
    int limit = 0,
    MP order = const {'created_at': true},
  }) async {
    var r = <MP>[];
    final col = <MP>[];

    final filterFutures = <Future<EventFractal>>[];
    for (var fe in filter.entries) {
      if (fe.value case String fs when EventFractal.isHash(fs)) {
        final key = fe.key;
        filterFutures.add(
          NetworkFractal.request<EventFractal>(fs).then((f) {
            filter[key] = f.id;
            return f;
          }),
        );
      }
    }

    await Future.wait(filterFutures);

    r = (await select(
      where: filter,
      limit: limit,
      order: order,
      //includeSubTypes: includeSubTypes,
    ))
        .reversed
        .where((m) {
      final same = m['type'] == name;
      if (!same) col.add(m);
      return same;
    }).toList();

    final fus = <Future<Fractal?>>[
      if (col.isNotEmpty) ...FilterF.collect(col),
    ];

    for (MP item in r) {
      final putF = put(MakeF(item)).then((f) => f, onError: (e) {
        print('failed making same: $e');
      });
      fus.add(putF);
      //fractals.add(f);
    }

    final items = await Future.wait(fus);

    return items.whereType<Fractal>();
  }

  /*
  //static final timerC = TimedF();
  Future<List<T>> collect(Iterable<int> ids) async {
    final res = await select(
      where: {'id': ids},
    );

    final fractals = <T>[];
    for (MP item in res) {
      final f = await put({
        ...item,
      });
      fractals.add(f);
    }
    return fractals;
  }
  */

  /*
  collect({required Iterable<int> only}) {
    final res = select(
      where: {'id': only},
    );
    preload(res);
  }
  */

  /*
  final _consumers = <Function(T)>[];
  consumer(Function(T) cb) {
    _consumers.add(cb);
  }

  consume(T event) {
    for (var c in _consumers) {
      c(event);
    }
  }
  */

  //static final map = <String, EventsCtrl>{};

  //Stream? _watcher;
  Future _load() async {
    /*>
    final select = db.select(db.events);
    //select.where((tbl) => tbl.syncAt.equals(0));
    select.orderBy([
      (tbl) => OrderingTerm(
            expression: tbl.createdAt,
            mode: OrderingMode.desc,
          ),
    ]);

    //_watcher = select.watch()..listen((event) {});

    select.get().then((list) {
      return preload([]);
      preload(
        list.map((row) {
          final m = row.toJson();
          if (m['id'] is! int) {
            m['hash'] = m.remove('id');
          }
          return m;
        }),
      );
    });
    /*
    (rows) {
      rows.forEach((row) {
        final m = row.toJson();
        m.remove('syncAt');
        m.remove('i');
        m['created_at'] = m['createdAt'];
        m['tags'] = [];
        m.remove('createdAt');
        //relay.send(m);
      });

      if (rows.isNotEmpty) Events.synched();
    };
    */
    */
  }
}
