import 'package:fractal/index.dart';

class NetworkCtrl<T extends NetworkFractal> extends NodeCtrl<T> {
  NetworkCtrl({
    super.name = 'network',
    required super.make,
    required super.extend,
    super.attributes = const <Attr>[],
  });

  @override
  init() {
    super.init();
  }
}

class NetworkFractal extends NodeFractal {
  static final controller = NetworkCtrl(
    extend: NodeFractal.controller,
    make: (d) => switch (d) {
      MP() => NetworkFractal.fromMap(d),
      Object() || null => throw ('wrong event type')
    },
  );

  @override
  NetworkCtrl get ctrl => controller;

  static NodeFractal? get actor =>
      UserFractal.active.value ?? DeviceFractal.active.value;
  static NetworkFractal? active;
  static SinkF? out;

  static Future<T> request<T extends EventFractal>(String hash) {
    final rq = EventFractal.storage.request(hash);
    if (!EventFractal.storage.containsKey(hash)) {
      CatalogFractal.pick(hash, (_) {
        out?.pick(hash);
      });
    }
    return rq as Future<T>;
  }

  NetworkFractal({
    required super.name,
    super.to,
  });

  NetworkFractal.fromMap(MP d) : super.fromMap(d);

  // Other methods and properties specific to ConnectionFractal
}
