import 'dart:typed_data';

import '../services/fs/ff.dart';
//export 'file/.dart' if (dart.library.html) 'file_idb.dart';

class ImageF extends FileF {
  static final _map = <String, ImageF>{};
  factory ImageF(String name) => _map[name] ??= ImageF.fresh(
        name,
      );
  factory ImageF.bytes(Uint8List bytes) {
    final name = FileF.hash(bytes);
    final file = _map[name] ??= ImageF.fresh(name);
    file.bytes = bytes;
    return file;
  }

  ImageF.fresh(super.name) : super.fresh();
}
