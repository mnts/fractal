import 'dart:async';
import 'dart:io';
import 'package:fractal/index.dart';
import 'package:collection/collection.dart';
import '../services/fs/platform/native/node.dart'
    if (dart.library.html) '../services/fs/platform/web/node.dart';

class NodeFractal<T extends EventFractal> extends EventFractal
    with
        Rewritable,
        InteractiveFractal,
        FlowF<T>,
        FilterF<T>,
        ExtendableF,
        HierarchyF,
        WithLinksF,
        FractalFS {
  static final controller = NodeCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => NodeFractal.fromMap(d),
      (String s) => NodeFractal(name: s),
      Object() || null => throw ('wrong event type')
    },
    attributes: [
      Attr(
        name: 'sorted',
        format: FormatF.text,
        canNull: true,
        def: '',
      ),
      Attr(
        name: 'name',
        format: FormatF.text,
        isImmutable: true,
        isIndex: true,
      ),
      Attr(
        name: 'folder',
        format: FormatF.text,
        d: {'ui': 'directory'},
        isImmutable: false,
        isPrivate: true,
        def: '',
      ),
      ExtendableF.attr,
      Attr(
        name: 'price',
        format: FormatF.real,
        isImmutable: false,
        isIndex: true,
        canNull: true,
      ),
    ],
    //indexes: {},
  );

  @override
  NodeCtrl get ctrl => controller;

  static final flow = TypeFilter<NodeFractal>(
    EventFractal.storage,
  );

  final SortedFrac<EventFractal> sorted;
  List<EventFractal> get sortedList => [
        ...sorted.value,
        ...list,
      ];

  List<EventFractal> get fullList => [
        ...sorted.value,
        ...sub.list,
      ];

  @override
  get uis => ui;
  static late Iterable<String> ui;

  @override
  get display {
    if (this['display'] case String d) {
      if (d[0] == '.') {
        if (this[d.substring(1)] case String reDisplay) return reDisplay;
      }
    }
    return title.value?.content ??
        name
            .replaceAll(
              RegExp('[^A-Za-z0-9-]'),
              ' ',
            )
            .toTitleCase;
  }

  Timer? sortTimer;
  sort() {
    sortTimer?.cancel();

    sortTimer = Timer(const Duration(seconds: 2), () {
      write('sorted', sorted.toString());
      sortTimer = null;
    });
  }

  MP d = {};

  double? price;

  @override
  //String get path => '/${ctrl.name}/$name';

  NodeFractal({
    this.name = '',
    super.to,
    this.price,
    super.createdAt,
    super.kind,
    this.d = const {},
    NodeFractal? extend,
    KeyPair? keyPair,
    List<EventFractal>? sub,
  }) : sorted = SortedFrac(sub ?? []) {
    this.name = name;

    this.extend = extend;
    listenExtended();
  }

  @override
  tell(m, {link}) async {
    switch (m) {
      case SparkF spark:
        switch (spark.map) {
          case {
              'execute': String exc,
            }:
            final ex = exc.split(' ');
            final res = await Process.run(
              ex.first,
              ex.sublist(1),
              workingDirectory: localPath,
            );

            if (res.stdout case String o) spark.map['out'] = o;
            if (res.stderr case String o) spark.map['err'] = o;
            return spark;
        }
    }
  }

  bool _initiated = false;
  @override
  Future<bool> initiate() async {
    if (_initiated) return true;
    _initiated = true;
    //sub.list.forEach(receive);
    //sub.listen(receive);
    localPath = await location;

    await initFS();
    await refresh();

    /*
    EventFractal(
      to: deviceInteraction,
    ).synch();
    */

    if (!onlyLocal) {
      NetworkFractal.out?.sink({
        'cmd': 'subscribe',
        'hash': hash,
      });
    }

    return super.initiate();
  }

  Future<EventFractal> point<E extends EventFractal>(MP m) async {
    final evf = EventFractal.controller.put({
      'to': this,
      ...m,
    });
    return await evf;
  }

  @override
  Future synch() async {
    final id = await super.synch();
    return id;
  }

  unSynch() {
    super.synch();

    if (!onlyLocal) {
      NetworkFractal.out?.sink({
        'cmd': 'unsubscribe',
        'hash': hash,
      });
    }

    //if (!onlyLocal) PostFractal(content: 'out', kind: 1, to: this).synch();
  }

  @override
  Future<bool> constructFromMap(m) async {
    setExtendable(m);
    return super.constructFromMap(m);
  }

  Future<List<NodeFractal>> discover() async {
    return [];
  }

  String name = '';
  String? folder;

  NodeFractal.fromMap(MP d)
      : name = d['name'] ?? '',
        price = d['price']?.toDouble(),
        folder = "${d['folder'] ?? ''}".isEmpty ? null : '${d['folder']}',
        sorted = SortedFrac([]),
        super.fromMap(d) {
    if (d['sorted'] case String s) {
      sorted.fromString(s);
    }
  }

  final title = Writable();
  FileF? file;
  ImageF? image;
  FileF? video;
  String? description;

  @override
  preload([type]) async {
    //myInteraction;
    await super.preload(type);
    //if (type == 'node') nodes;

    await initiate();
    await preloadExtend();
    return 1;
  }
  /*
  FileF? get image => _image ?? extend?.image;
  set image(FileF? v) {
    _image = v;
  }
  */

  var tags = <String>[];

  @override
  onWrite(f) async {
    final ok = await super.onWrite(f);
    if (ok) {
      switch (f.attr) {
        case 'title':
          title.value = f;
        case 'folder':
          if (f.content.isNotEmpty) {
            await controller.update({
              f.attr: f.content,
            }, id);
            folder = f.content;
          }
        case 'price':
          final val = double.tryParse(f.content);
          if (val != null && price != val) {
            await controller.update({
              'price': val,
            }, id);
            price = val;
          }
        case 'description':
          description = f.content;
        case 'tags':
          (f.content.isEmpty) ? tags.clear() : tags = f.content.split(' ');
        case 'sorted':
          sorted.fromString(f.content).then((r) {
            //print("sorted: ${r.map((f) => f.hash).join(',')}");
          });
        case 'image':
          image = ImageF(f.content);
        case 'video':
          video = FileF(f.content);
        //super.onWrite(f);
      }
      notifyListeners();
    }
    return ok;
  }

  @override
  resolve(key) {
    if (this[key] case Object val) {
      return val;
    }
    return switch (key) {
      'price' => price ?? extend?[key] ?? super[key],
      _ => m[key]?.content ??
          sub[key] ??
          sorted.value.firstWhereOrNull(
            (t) => t is NodeFractal && t.name == key,
          ) ??
          extend?.resolve(key) ??
          super.resolve(key) ??
          to?.resolve(key)
    };
  }

  @override
  operator [](key) => switch (key) {
        'name' => name,
        'price' => price,
        'folder' => folder,
        'extend' => extend?.hash,
        _ => m[key]?.content ?? super[key] ?? d[key],
      };
}
