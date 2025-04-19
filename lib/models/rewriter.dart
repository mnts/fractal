import '../index.dart';

mixin Rewritable on EventFractal {
  final m = MapEvF<WriterFractal>();

  Future<bool> onWrite(WriterFractal f) async {
    /*
    EventsCtrl c = ctrl;
    while (c.attributes.any((attr) => attr.name == f.attr)) {
      if (c.extend is! EventsCtrl) {
        continue;
      }
    }
    */
    return m.completeNew(f.attr, f);
  }
  //Object? operator [](String key) => super[key] ?? m[key]?.content ?? extend?[key];

  /*>
  static Future<T> ext<T extends EventFractal>(
    MP d,
    Future<T> Function() cb,
  ) async {
    NodeFractal? extended;
    if (d['extend'] case String extend)lk {
      if (await NetworkFractal.request(extend) case NodeFractal ext) {
        extended = ext;
        d['type'] ??= extended.type;
      }
    }

    final f = cb();

    final item = await f;
    if (extended != null && item is NodeFractal) {
      item.extend = extended;
      extended.extensions.complete(item.hash, item);
      item.notifyListeners();
    }

    return f;
  }
  */
}

class Writable extends Frac<WriterFractal?> {
  Writable() : super(null);

  @override
  toString() => value?.content ?? '';
}

extension RewritableExt on Rewritable {
  write(String attr, String content) {
    WriterFractal(
      attr: attr,
      content: content,
      to: this,
      owner: NetworkFractal.actor,
    ).synch();
  }

  @override
  operator []=(key, value) {
    if (key is String) {
      write(key, value);
    }
  }
}

class WriterCtrl<T extends WriterFractal> extends EventsCtrl<T> {
  WriterCtrl({
    super.name = 'writer',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class WriterFractal extends EventFractal {
  static final controller = WriterCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => WriterFractal.fromMap(d),
      Object() || null => throw ('wrong rewriter given')
    },
    attributes: <Attr>[
      Attr(
        name: 'attr',
        format: FormatF.text,
        isImmutable: true,
      ),
    ],
  );

  @override
  WriterCtrl get ctrl => controller;
  final String attr;

  WriterFractal({
    required this.attr,
    required super.content,
    required super.to,
    super.owner,
  });

  @override
  provide(into) {
    if (into case Rewritable re) re.onWrite(this);
  }

  get display => '$attr: $content';

  //TODO: make remove old after initiation

  @override
  synch() async {
    await super.synch();

    await ctrl.query("""
      DELETE FROM fractal
      WHERE id IN (
        SELECT writer.id
        FROM writer
        INNER JOIN event
        ON event.id=writer.id
        WHERE event.created_at < ? 
        AND event."to" = ? AND writer.attr = ?
      );
    """, [createdAt, to?.id, attr]);
  }

  WriterFractal.fromMap(MP d)
      : attr = d['attr'],
        super.fromMap(d);

  @override
  operator [](key) => switch (key) {
        'attr' => attr,
        _ => super[key],
      };
}
