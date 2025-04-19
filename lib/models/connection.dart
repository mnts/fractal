import 'package:fractal/index.dart';

import '../fr.dart';
import 'index.dart';

class ConnectionCtrl<T extends ConnectionFractal> extends InteractionCtrl<T> {
  ConnectionCtrl({
    super.name = 'connection',
    required super.make,
    required super.extend,
    super.attributes = const <Attr>[],
  });
}

class ConnectionFractal extends InteractionFractal {
  static final controller = ConnectionCtrl(
    extend: InteractionFractal.controller,
    make: (d) => switch (d) {
      MP() => ConnectionFractal.fromMap(d),
      Object() || null => throw ('wrong event type')
    },
    attributes: [
      Attr(
        name: 'from',
        format: FormatF.reference,
        isImmutable: true,
        isIndex: true,
      ),
    ],
  );
  @override
  ConnectionCtrl get ctrl => controller;

  @override
  initiate() async {
    return super.initiate();
  }

  final NodeFractal from;

  ConnectionFractal({
    required this.from,
    required super.to,
  });

  ConnectionFractal.fromMap(super.d)
      : from = d['from'],
        super.fromMap();

  @override
  operator [](key) => switch (key) {
        'from' => from.hash,
        _ => super[key],
      };
  // Other sfdgfdgsdfgmethods and properties specific to ConnectionFractal
}
