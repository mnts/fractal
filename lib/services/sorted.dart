import 'package:fractal/index.dart';

class SortedFrac<T extends EventFractal> extends Frac<List<T>> {
  SortedFrac(super.value, {this.onMove});
  Function()? onMove;
  bool dontNotify = false;

  order(T f, [int? pos]) {
    value.remove(f);
    if (pos == null || value.isEmpty || pos > value.length) {
      value.add(f);
    } else {
      value.insert(pos, f);
    }
    notifyListeners();
  }

  remove(T ev) {
    value.remove(ev);
    notifyListeners();
  }

  int get length => value.length;

  Future<List<T>> fromString(String s) async {
    final hashes = s.split(',');
    var list = List<T?>.filled(hashes.length, null);
    final fus = List<Future<T>>.generate(
      hashes.length,
      (i) => NetworkFractal.request<T>(hashes[i]),
    );

    /*
    await Future.forEach<String>(hashes, (h) async {
      final i = hashes.indexOf(h);
      list[i] = await NetworkFractal.request<T>(h);
      value = list.whereType<T>().toList();
    });
    */

    fus.asMap().entries.forEach((en) {
      en.value.then((f) {
        list[en.key] = f;
        value = list.whereType<T>().toList();
        notifyListeners();
      });
    });

    return Future.wait(fus);
  }

  add(T f) {
    value.add(f);
    notifyListeners();
  }

  @override
  toString() => value.map((f) => f.hash).join(',');
}
