import 'package:fractal/fractal_base.dart';

Future<EventFractal> f$(MP map) {
  final ctrl = FractalCtrl.map[map['type']] as EventsCtrl;
  return ctrl.put(map);
}
