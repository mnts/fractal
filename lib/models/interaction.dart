import '../index.dart';

class InteractionCtrl<T extends InteractionFractal> extends EventsCtrl<T> {
  InteractionCtrl({
    super.name = 'interaction',
    required super.make,
    required super.extend,
    super.attributes = const <Attr>[],
  });
}

mixin InteractiveFractal on EventFractal {
  final interactions = MapEvF<InteractionFractal>();
  interactiveFractal() {}

  addInteraction(InteractionFractal f) {
    /*
    if (f.own) {
      _myInteraction = f;
    }

    f.ownerC.future.then((owner) {
      if (owner == null) return;
      interactions.complete(owner.hash, f);
    });
    */
  }

  Future<InteractionFractal> get myInteraction =>
      UserFractal.active.value != null ? accountInteraction : deviceInteraction;

  late final deviceInteraction = InteractionFractal.controller.put({
    'to': this,
    'owner': DeviceFractal.my,
    'kind': 3,
  });

  late final accountInteraction = InteractionFractal.controller.put({
    'to': this,
    'owner': UserFractal.active.value!,
    'kind': 3,
  });
}

class InteractionFractal extends EventFractal with Rewritable {
  static final controller = InteractionCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => InteractionFractal.fromMap(d),
      _ => throw ('wrong')
    },
  );

  @override
  InteractionCtrl get ctrl => controller;

  @override
  List get hashData => [0, pubkey, to?.key ?? '', type];

  InteractionFractal({
    super.to,
    super.owner,
    super.kind = FKind.eternal,
  });

  @override
  provide(into) {
    switch (into) {
      case InteractiveFractal re:
        re.addInteraction(this);
    }
    super.provide(into);
  }

  InteractionFractal.fromMap(MP d) : super.fromMap(d);
  @override
  onWrite(f) {
    return switch (f.attr) {
      _ => super.onWrite(f),
    };
  }
}
