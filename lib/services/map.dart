import '../index.dart';

class MapEvF<T extends EventFractal> extends MapF<T> {
  MapEvF();

  @override
  notify(T fractal) {
    if (fractal.state == StateF.removed) {
      cleanUp();
    }
    super.notify(fractal);
  }

  @override
  input(T f) {
    complete(f.hash, f);
  }

  bool completeNew(Object key, T event) {
    print('complete: $key');
    final current = map[key];
    return (current == null || current.createdAt <= event.createdAt)
        ? super.complete(key, event)
        : false;
  }

  MP get writtenMap => <String, Object>{
        for (var w in list.whereType<WriterFractal>()) w.attr: w.content,
      };
}
