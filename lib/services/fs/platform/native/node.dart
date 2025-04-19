import 'dart:io';
import 'package:fractal/index.dart';
import '../../index.dart';

extension NodeFractalNativeIO on NodeFractal {
  Future initFS() async {
    //if (!await isMy) return;
    final f = File(localPath);
    final stat = await f.stat();
    fType = _getFType(stat.type);

    switch (fType) {
      case FileFractalType.directory:
        final dir = Directory(localPath);
        dir.list().listen((fse) async {
          await makeEntity(fse);
        });
      case _:
    }
    return;
  }

  Future<FractalFS?> makeEntity(FileSystemEntity fse) async {
    final st = await File(fse.path).stat();
    final name = fse.path.split('/').last;
    final type = _getFType(st.type);
    final mk = MakeF({
      'name': name,
      'to': this,
      'kind': FKind.file.index,
    });

    print(mk);

    final fractal = await switch (type) {
      FileFractalType.directory => NodeFractal.controller.put(mk),
      FileFractalType.file => FileFractal.controller.put(mk),
      _ => null,
    };
    fractal?.synch();
    return fractal;
  }

  static FileFractalType _getFType(FileSystemEntityType type) => switch (type) {
        FileSystemEntityType.file => FileFractalType.file,
        FileSystemEntityType.directory => FileFractalType.directory,
        _ => FileFractalType.unknown,
      };
}
