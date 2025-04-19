import 'index.dart';

class FData {
  static Future<List<Fractal?>> require(MakeF mk, List keys) {
    final fus = <Future<Fractal?>>[];

    for (var key in keys) {
      final val = mk.map[key];
      if (val is Fractal) continue;
      final fu = switch (val) {
        String hash when hash.isNotEmpty => CatalogFractal.pick(
            hash,
            (_) {
              var sink = NetworkFractal.out;
              if (mk.by case SinkF s when sink == null) {
                sink = s;
              }
              sink?.pick(hash);
            },
          ),
        int id when id > 0 => _byId(id),
        Fractal f => Future.value(f),
        _ => null,
      };

      if (fu != null) {
        fus.add(fu.then((f) async {
          mk.map[key] = f;
          return f;
        }));
      } else {
        mk.map.remove(key);
      }
    }

    return Future.wait(fus);
  }

  //static final completer = CompleterF<int>()..cb = _completeById;
  static final _idTimer = TimedF();
  static Future<Fractal?> _byId(int id) async {
    if (Fractal.storage[id] case Fractal f) return f;
    final rq = Fractal.storage.request(id);

    _idTimer.hold(_completeById, 30);

    //completer.hold(id).then((a) => Fractal.storage[id]);
    return rq;
  }

  static final puts = <String, EventFractal>{};

  static final _collectingIds = <int>[];
  static Future _completeById() async {
    final ids = [
      ...Fractal.storage.requests.keys
          .whereType<int>()
          .where((id) => !_collectingIds.contains(id))
          .where((id) => !Fractal.storage.containsKey(id)),
    ];
    if (ids.isEmpty) return;

    print('complete $ids');
    _collectingIds.addAll(ids);

    if (ids.isNotEmpty) {
      await EventFractal.controller.find({
        'id': ids,
      });
    }

    for (var id in ids) {
      print('completed $id ${Fractal.storage[id]}');
    }

    return;
  }
}
