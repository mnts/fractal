import 'package:fractal/index.dart';

class TypeFilter<T extends EventFractal> extends MapF<T> {
  final FlowF<EventFractal> from;
  TypeFilter(this.from) {
    from.listen(receive);
    for (var f in from.list) {
      receive(f);
    }
  }

  receive(EventFractal? f) {
    if (f is T) {
      complete(f.hash, f);
    }
  }
}
