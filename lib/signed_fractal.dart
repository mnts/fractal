import 'index.dart';

class SignedFractal {
  static final ctrls = <FractalCtrl>[
    Fractal.controller,
    EventFractal.controller,
    WriterFractal.controller,
    NodeFractal.controller,
    FileFractal.controller,
    //FilterFractal.controller,
    CatalogFractal.controller,
    InteractionFractal.controller,
    ConnectionFractal.controller,
    NetworkFractal.controller,
  ];

  static Future<int> init() async {
    for (final el in ctrls) {
      await el.init();
    }
    await UserFractal.init();

    return 1;
  }
}
