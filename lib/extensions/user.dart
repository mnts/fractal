import 'package:fractal/models/user.dart';

import '../models/node.dart';

extension UserFractalExt on UserFractal {
  Future<NodeFractal> startChat() async {
    final hashes = [
      UserFractal.active.value!.hash,
      hash,
    ];

    hashes.sort();

    final chatFu = NodeFractal.controller.put({
      'name': 'chat:${hashes.join(',')}',
      'created_at': 0,
    });

    return chatFu;
  }
}
