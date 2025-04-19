import 'dart:async';
import 'package:fractal/index.dart';

import 'index.dart';

class FSys {
  FSys();

  static final errors = Frac<List<String>>([]);
  static void error(String e) {
    errors.value.add(e);
    Timer(Duration(seconds: 5), () {
      errors.value.remove(e);
      errors.notifyListeners();
    });
  }

  static final ctrlMap = <String, NodeFractal>{};

  static late final NodeFractal system;

  static late final NodeFractal ctrls;

  static Future setup() async {
    AFI.init();
    system = await NodeFractal.controller.put({
      'name': 'system',
      'kind': FKind.system.index,
    });
    await system.synch();
    //EventFractal.storage['system'] = system;
    ctrls = await NodeFractal.controller.put({
      'name': 'controllers',
      'to': system,
      'kind': FKind.system.index,
    });
    await ctrls.synch();

    //EventFractal.storage['ctrls'] = ctrls;

    for (final ctrl in FractalCtrl.map.values) {
      if (ctrl is! FlowF) continue;
      final ext = ctrl.extend.name;
      final m = {
        'name': ctrl.name,
        'to': ctrls.hash,
        'source': ctrl.name,
        if (ext != 'fractal') 'extend': ctrlMap[ext]!.hash,
        'kind': FKind.system.index,
      };
      final c = await CatalogFractal.controller.put(m);
      c.d = {
        'icon': ctrl.name,
      };
      ctrlMap[ctrl.name] = c;
      ctrl.node = c;
      // await c.synch();

      for (final attr in ctrl.attributes) {
        Attr.controller.input(attr);
        attr.to = c;
        attr.consumable();
        attr.complete();
        //EventFractal.storage.complete(hash, this);
        //attr.complete();
      }
    }

    NetworkFractal.active = await NetworkFractal.controller.put({
      'name': FileF.host,
      'kind': 3,
      'pubkey': '',
    });
    await NetworkFractal.active?.synch();

    AppFractal.main = await AppFractal.controller.put({
      'name': FileF.host,
      'kind': 3,
      'owner': '',
      'sync_at': 1,
    });
    await AppFractal.main.synch();

    return;
  }
}
