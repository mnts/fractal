import 'package:fractal/index.dart';

class LinksCtrl<T extends LinkFractal> extends EventsCtrl<T> {
  LinksCtrl({
    super.name = 'link',
    required super.make,
    required super.extend,
    required super.attributes,
  }) {
    //initSql();
  }
}
