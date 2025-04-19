import 'dart:async';
import 'dart:convert';
import 'package:fractal/index.dart';

import '../mixins/filterable.dart';
import '../sys.dart';

class CatalogCtrl<T extends CatalogFractal> extends NodeCtrl<T> {
  CatalogCtrl({
    super.name = 'catalog',
    required super.make,
    required super.extend,
    required super.attributes,
  });

  /*
  @override
  Future<void> init() async {
    await super.init();

    return;
  }
  */

  @override
  put(d) async {
    final mk = MakeF.init(d);
    if (mk.map['source'] case String s) {
      mk.map['source'] = (EventFractal.isHash(s))
          ? (await NetworkFractal.request(s))
          : FractalCtrl.map[s];
    }
    return super.put(mk);
  }
}

class CatalogFractal<T extends EventFractal> extends NodeFractal<T> {
  static final controller = CatalogCtrl(
      extend: NodeFractal.controller,
      make: (d) => switch (d) {
            MP() => CatalogFractal.fromMap(d),
            _ => throw ('wrong'),
          },
      attributes: <Attr>[
        Attr(
          name: 'filter',
          format: FormatF.text,
          canNull: true,
          isImmutable: true,
        ),
        Attr(
          name: 'order',
          format: FormatF.text,
          canNull: true,
          isImmutable: true,
        ),
        Attr(
          name: 'source',
          format: FormatF.text,
          canNull: true,
          isImmutable: true,
        ),
        Attr(
          name: 'mode',
          format: FormatF.text,
          isImmutable: true,
        ),
        Attr(
          name: 'limit',
          format: FormatF.integer,
          def: '0',
        ),
      ]);

  @override
  CatalogCtrl get ctrl => controller;

  //final FlowF<EventFractal> from;
  @override
  final Map<String, dynamic> order;
  @override
  //final bool includeSubTypes;

  @override
  FlowF<T>? source;

  @override
  Map<String, dynamic> filter = {};

  List<String> get mode => [
        //if (!includeSubTypes) 'noSub',
      ];

  @override
  bool onlyLocal;

  //bool uptodate = false;

  // either if offline or subscrived
  /*
  FutureOr<bool> get whenReady async =>
      (await whenLoaded && !ClientFractal.main!.active.value) ||
      await whenSubscribed;
  */

  static const defaultOrder = {'created_at': true};

  CatalogFractal({
    super.to,
    this.filter = const {},
    this.order = defaultOrder,
    this.source,
    this.limit = 0,
    super.kind,
    //this.includeSubTypes = true,
    this.onlyLocal = false,
  }) {
    _construct();
  }

  static Future<CatalogFractal> put({
    Map<String, dynamic> filter = const {},
    Map<String, dynamic> order = defaultOrder,
    String source = 'event',
    bool includeSubTypes = true,
    int limit = 0,
    bool onlyLocal = false,
  }) async {
    final c = await controller.put({
      'filter': filter,
      'order': order,
      'source': source,
      'mode': """
${(!includeSubTypes) ? 'noSub' : ''}
""",
      'onlyLocal': onlyLocal,
      'limit': limit,
      'kind': 3,
    });
    c.synch();
    return c;
  }

  CatalogFractal.fromMap(super.d)
      : filter = switch (d['filter']) {
          String s => switch (s) {
              'null' => {},
              _ => jsonDecode(s),
            },
          Map m => {...m},
          _ => {},
        },
        order = switch (d['order']) {
          String s => switch (s) {
              'null' => defaultOrder,
              _ => jsonDecode(s),
            },
          Map m => {...m},
          _ => defaultOrder,
        },
        source = d['source'],
        limit = d['limit'] ?? 0,
        //includeSubTypes = !"${d['mode']}".contains('noSub'),
        onlyLocal = false,
        super.fromMap() {
    _construct();
  }

  @override
  Future synch() async {
    final id = await super.synch();
    initiate();
    return id;
  }

  int limit;

  @override
  Object? operator [](key) => switch (key) {
        'filter' => jsonEncode(filter),
        'order' => jsonEncode(order),
        'source' => switch (source) {
            CatalogFractal c => c.hash,
            EventsCtrl ctrl => ctrl.name,
            _ => null,
          },
        'mode' => [...mode..sort()].join(','),
        _ => super[key],
      };

  Function(Map)? reMake;

  @override
  Future tell(m, {link}) async {
    switch (m) {
      case InteractionFractal f:
        final map = f.m.writtenMap;
        if (source case EventsCtrl ctrl) {
          return await ctrl.put(map)
            ..synch();
        }
        break;
        _:
        super.tell(m);
    }
    ;
  }

  /*
  static String? findType(dynamic h) {
    final rows = switch (h) {
      String s => EventFractal.controller.select(
          limit: 1,>
          subWhere: {
            'event': {'hash': s},
          },
          includeSubTypes: true,
        ),
      int id => Fractal.controller.select(Future<EventFractal>
          limit: 1,
          subWhere: {
            'event': {'id': id},
          },
          includeSubTypes: true,
        ),
      _ => [],
    };

    return rows.isEmpty ? null : rows[0]['type'];
  }
  */

  void _construct() {}

  @override
  Future<bool> construct() async {
    if (filter.isEmpty) {
      if (source case EventsCtrl evCtrl) {
        FSys.ctrls.sub.completeNew(evCtrl.name, this);
      }
    }
    return await super.construct();
  }

  @override
  bool input(f) {
    final re = super.input(f);
    if (re) reOrder();
    return re;
  }

  reOrder() async {
    return;
    if (!loaded.isCompleted) return;
    list.sort((a, b) {
      final by = order.entries.first;
      final av = a[by.key];
      final bv = b[by.key];
      if (av is Comparable && bv is Comparable) {
        return by.value ? bv.compareTo(av) : av.compareTo(bv);
      }
      return 0;
    });
    notifyListeners();
  }

  //static final timer = TimedF();
  //static final Map<String, Function(String h)?> picking = {};

  static Future<List<E>> pickMany<E extends EventFractal>(List<String> list) =>
      Future.wait<E>(
        List<Future<E>>.generate(
          list.length,
          (i) => NetworkFractal.request<E>(list[i]),
        ),
      );

  /*
    for (var i = 0; i < list.length; i++) {
      final h = list[i];
      NetworkFractal.request(h).then((f) {
        if (f is T) {
          order(f, i);
        }
      });
    }
    */
  //dontNotify = false;

  static final timer = TimedF();
  static final Map<String, Function(String h)?> picking = {};

  static Future<EventFractal> pick(
    String h, [
    void Function(String h)? miss,
  ]) async {
    //List<String> picking = [];
    var fractal = EventFractal.storage[h];
    if (fractal != null) return fractal;

    final rq = EventFractal.storage.request(h);

    if (picking.containsKey(h)) {
      return rq;
    }

    rq.then((f) {
      picking.remove(f.hash);
    });

    picking[h] = miss;

    timer.hold(() async {
      if (picking.isEmpty) return true;
      final r = await EventFractal.controller.select(
        fields: ['hash', 'type'],
        where: {
          'hash': [...picking.keys]
        },
        //includeSubTypes: true,
      );

      for (var m in r) {
        final h = m['hash'];
        picking.remove(h);
      }

      for (final entry in picking.entries) {
        final miss = entry.value;
        if (miss != null) miss(entry.key);
      }

      FilterF.collect(r);
      return true;
    }, 20);
    return rq;
  }
}
