import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:fractal/index.dart';
import 'index.dart';

class FileCtrl<T extends FileFractal> extends NodeCtrl<T> {
  FileCtrl({
    super.name = 'file',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class FileFractal extends NodeFractal {
  static final controller = FileCtrl(
    make: (d) => switch (d) {
      MP() => FileFractal.fromMap(d),
      Object() || null => throw ('wrong event type')
    },
    extend: NodeFractal.controller,
    attributes: [],
  );

  late final fs = File(localPath);
  Completer<void>? fsReading;

  static Future init() async {
    await controller.init();
  }

  @override
  Future<bool> initiate() async {
    await super.initiate();
    await initFile();

    return true;
  }

  @override
  tell(m, {link}) async {
    switch (m) {
      case SparkF spark:
        switch (spark.map) {
          case {
              'cmd': 'write',
              'data': Object data,
            }:
            switch (data) {
              case String str:
                write(
                  utf8.encoder.convert(str),
                );
              case FileF file:
                write(file.bytes);
              case Map map:
                write(
                  utf8.encoder.convert(
                    switch (spark.map['format']) {
                      _ => jsonEncode(map),
                    },
                  ),
                );
              case Uint8List b:
                write(b);
            }
        }
    }
  }

  /*
  static Future<FileFractal> trace(String path) async {
    final pathL = path.split('/');

    NodeFractal current = DeviceFractal.my;

    for (String name in pathL) {
      if (name == '') continue;
      current = await controller.put(MakeF({
        'name': name,
        'to': current,
        'created_at': 1,
      }));
      //await current.synch();
    }
    return current as FileFractal;
  }
  */

  @override
  FileCtrl get ctrl => controller;

  static final flow = TypeFilter<FileFractal>(
    NodeFractal.flow,
  );

  /*
  Future<NodeFractal?> get _root async {
    NodeFractal? current = this;
    while (current is! DeviceFractal &&
        current != null &&
        current.folder == null) {
      current = current.to as NodeFractal;
    }
    return (current); // is DeviceFractal) ? current : null;
  }
  */

  @override
  //String get path => '${device?.hash ?? '/'}/_path';

  @override
  String get display => name;

  NodeFractal? root;

  @override
  preload([type]) async {
    //root = await _root;
    return super.preload(type);
  }

  @override
  FileFractal({
    super.to,
    super.extend,
    required super.name,
  }) {
    //map.complete(name, this);
  }

  FileFractal.fromMap(super.d) : super.fromMap();

  @override
  Object? operator [](key) => switch (key) {
        'icon' => m['icon']?.content,
        'ui' => m['ui']?.content ?? fsUI ?? super[key],
        _ => super[key],
      };
}
