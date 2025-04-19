import 'package:fractal/types/index.dart';
import 'package:fractal/models/index.dart';
import 'package:fractal/models/node.dart';
import '../models/event.dart';
import 'events.dart';

class NodeCtrl<T extends NodeFractal> extends EventsCtrl<T> {
  NodeCtrl({
    super.name = 'node',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}
