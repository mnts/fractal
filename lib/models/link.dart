import 'package:fractal/index.dart';

/// Class that carries all link data.
class LinkFractal extends EventFractal with ExtendableF {
  static final controller = LinksCtrl(
    make: (d) => LinkFractal.fromMap(d),
    extend: EventFractal.controller,
    attributes: [
      Attr(
        name: 'target',
        format: FormatF.reference,
      ),
      ExtendableF.attr,
    ],
  );

  @override
  LinksCtrl get ctrl => controller;

  EventFractal target;

  //var linkPoints = <OffsetF>[];

  LinkFractal({
    super.id,
    super.to,
    required this.target,
    super.content,
    NodeFractal? extend,
    //this.data,
  }) {
    init();

    this.extend = extend;
    listenExtended();
  }

  @override
  Future<bool> constructFromMap(m) async {
    setExtendable(m);
    return super.constructFromMap(m);
  }

  init() async {
    if (to case WithLinksF source) {
      source.addLink(this);
    }
    if (target case WithLinksF target) {
      target.addLink(this);
    }

    notifyListeners();
  }

  LinkFractal.fromMap(d)
      : target = d['target'],
        super.fromMap(d) {
    init();
  }

  //late var style = makeStyle;

  @override
  String get display => '↜';

  @override
  resolve(key) => this[key] ?? extend?[key];

  @override
  operator [](key) => switch (key) {
        'target' => target.hash,
        'extend' => extend?.hash,
        _ => super[key],
      };
}
