/*
import '../controllers/events.dart';
import '../index.dart';
import 'event.dart';

class PostCtrl<T extends PostFractal> extends EventsCtrl<T> {
  PostCtrl({
    super.name = 'post',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class PostFractal extends EventFractal {
  static final controller = PostCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => PostFractal.fromMap(d),
      _ => throw ('wrong rewriter given')
    },
    attributes: <Attr>[
    ],
  );

  PostCtrl get ctrl => controller;

  final String content;
  FileF? file;
  int kind;

  PostFractal({
    required this.content,
    this.file,
    super.to,
    this.kind = 0,
    super.owner,
  });

  @override
  get display => content;

  PostFractal.fromMap(super.d)
      : content = '${d['content'] ?? ''}',
        kind = d['kind'] ?? 0,
        file = d['file'] is String && (d['file'] as String).isNotEmpty
            ? FileF(d['file'])
            : null,
        super.fromMap();

  @override
  operator [](String key) => switch (key) {
        'content' => content,
        'file' => file?.name ?? '',
        _ => super[key],
      };

  @override
  MP toMap() => {
        ...super.toMap(),
        for (var a in controller.attributes) a.name: this[a.name],
      };
}
*/
