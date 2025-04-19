import 'dart:async';

import '../frac/frac.dart';
import '../models/fractal.dart';

mixin WithNotifications on Fractal {
  final errors = Frac<List<String>>([]);
  void error(String e) {
    errors.value.add(e);
    errors.notifyListeners();
    Timer(Duration(seconds: 4), () {
      errors.value.remove(e);
      errors.notifyListeners();
    });
  }
}
