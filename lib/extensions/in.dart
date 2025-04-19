import 'package:fractal/index.dart';

extension NodeInFExt on NodeFractal {
  Future<List<EventFractal>> inNode(NodeFractal reNode) async {
    await reNode.preload('node');
    if (reNode == this) return fullList;
    final list = <EventFractal>[];
    for (var ev in fullList) {
      await ev.preload();
      final ifStr = '${ev['if'] ?? ''}';
      bool good = true;
      if (ifStr.isNotEmpty) {
        for (var str in ifStr.split(',')) {
          if (str.isNotEmpty && str[0] == '!') {
            str = str.substring(1);
            good = !(await testIf(str, reNode));
          } else {
            good = await testIf(str, reNode);
          }
          if (!good) break;
        }
      }

      if (good) list.add(ev);
    }
    return list;
  }

  static Future<bool> testIf(String str, NodeFractal reNode) async {
    if (str.contains('in')) {
      var [leftS, rightS] = str.split('in');
      leftS = leftS.trim();
      rightS = rightS.trim();
      if (leftS.isEmpty && rightS.isEmpty) return false;

      final hash = switch (leftS) {
        '' => reNode.hash,
        'owner' => reNode.owner?.hash,
        'account' => UserFractal.active.value?.hash,
        _ => reNode.sub[leftS]?.hash ?? reNode[leftS] as String?,
      };

      final rightF = (rightS.isEmpty)
          ? reNode
          : (EventFractal.isHash(rightS)
              ? (await NetworkFractal.request(rightS))
              : reNode.sub[rightS]);

      final sorted = '${rightF?['sorted'] ?? ''}'.split(',');
      if (!sorted.contains(hash)) return false;
    } else if (!switch (str) {
      'authenticated' => UserFractal.active.value != null,
      'own' => (reNode.owner) == UserFractal.active.value,
      _ => false,
    }) {
      return false;
    }
    return true;
  }
}
