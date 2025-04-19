import 'package:collection/collection.dart';

import 'thing.dart';

class RefF {
  static final expressions = <RegExp, ThingF Function(String)>{};
  static List parseContent(String content) => [
        for (var c in content.split(' '))
          expressions.entries
                  .firstWhereOrNull(
                    (e) => e.key.hasMatch(c),
                  )
                  ?.value(c) ??
              c
      ];
}
