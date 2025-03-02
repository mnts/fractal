import 'package:fractal/fractal.dart';

extension FractalMatch on FilterableF {
  bool match(MP filter) {
    return filter.entries.every((e) {
      dynamic value = this[e.key];
      return switch (e.value) {
        String s => (s.length > 2 &&
                s[0] == '%' &&
                s[s.length - 1] == '%' &&
                value is String)
            ? value.contains(
                s.substring(1, s.length - 1),
              )
            : value == s,
        int i => value == i,
        Map m => m.entries
            .map((e) => switch (e.key) {
                  'gt' => value > e.value,
                  'gte' => value >= e.value,
                  'lt' => value < e.value,
                  'lte' => value <= e.value,
                  'in' => e.value.contains(value),
                  'nin' => !e.value.contains(value),
                  _ => false,
                })
            .every((t) => t),
        double d => value == d,
        false => value == false || '$value' == '' || value == null,
        true => value == true || '${value ?? ''}'.isNotEmpty,
        null => true,
        _ => false,
      };
    });
  }
}
