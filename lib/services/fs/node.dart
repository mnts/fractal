import 'package:fractal/index.dart';

extension NodeFractalIO on NodeFractal {
  Future<String> get location async {
    String path = name;
    if (folder?.isNotEmpty == true) return folder!;
    NodeFractal? current = this;
    while (current != null) {
      current = current.to as NodeFractal?;
      if (current is DeviceFractal ||
          current == null ||
          current.folder != null) {
        return '${current?.folder ?? ''}/$path';
      }
      path = '${current.name}/$path';
    }

    return path;
  }

  //initFS() {}
}
