import '../frac/fnotifier.dart';

mixin MPF on FChangeNotifier {
  @override
  void operator []=(String key, value) {
    // TODO: implement []=
  }

  @override
  void addAll(Map<String, dynamic> other) {
    // TODO: implement addAll
  }

  @override
  void addEntries(Iterable<MapEntry<String, dynamic>> newEntries) {
    // TODO: implement addEntries
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String key, value)) {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  void clear() {
    // TODO: implement clear
  }

  @override
  bool containsKey(Object? key) {
    // TODO: implement containsKey
    throw UnimplementedError();
  }

  @override
  bool containsValue(Object? value) {
    // TODO: implement containsValue
    throw UnimplementedError();
  }

  @override
  // TODO: implement entries
  Iterable<MapEntry<String, dynamic>> get entries => throw UnimplementedError();

  @override
  void forEach(void Function(String key, dynamic value) action) {
    // TODO: implement forEach
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement keys
  Iterable<String> get keys => throw UnimplementedError();

  @override
  // TODO: implement length
  int get length => throw UnimplementedError();

  @override
  putIfAbsent(String key, Function() ifAbsent) {
    // TODO: implement putIfAbsent
    throw UnimplementedError();
  }

  @override
  remove(Object? key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  void removeWhere(bool Function(String key, dynamic value) test) {
    // TODO: implement removeWhere
  }

  @override
  update(String key, Function(dynamic value) update, {Function()? ifAbsent}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  void updateAll(Function(String key, dynamic value) update) {
    // TODO: implement updateAll
  }

  @override
  // TODO: implement values
  Iterable get values => throw UnimplementedError();
}
