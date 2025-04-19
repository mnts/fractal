import 'dart:convert';
import '../index.dart';
import 'index.dart';

class AFI {
  static init() {
    final methods = {
      'intoJSON': (MP m) => jsonEncode(m),
      'fromJSON': (String s) => jsonDecode(s),
      'random': (int n) => getRandomString(4),
      'intoName': (String s) => formatFName(s),
    };

    Transformer.methods.addAll(methods);
  }
}
