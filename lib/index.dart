export 'c.dart';
export 'data.dart';
export 'models/fractal.dart';
export 'lib.dart';
export 'map.dart';
export 'ref.dart';
export 'utils.dart';
export 'filter/index.dart';
export 'sys.dart';
export 'db.dart';
export 'afi/index.dart';
export 'filters/index.dart';
export 'frac/index.dart';
export 'types/index.dart';
export 'models/index.dart';
export 'interfaces/index.dart';
export 'mixins/index.dart';
export 'enums/index.dart';
export 'extensions/index.dart';
export 'controllers/index.dart';
export 'services/index.dart';
export 'security/index.dart';
export 'controllers/controllers.dart';
export 'index.dart';
export 'policies/policies.dart';
export 'utils/index.dart';
import 'index.dart';

class SignedFractal {
  static final ctrls = <FractalCtrl>[
    Attr.controller,
    DeviceFractal.controller,
    Fractal.controller,
    EventFractal.controller,
    WriterFractal.controller,
    NodeFractal.controller,
    AppFractal.controller,
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
