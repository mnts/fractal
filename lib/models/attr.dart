import 'package:fractal/index.dart';

enum FormatF {
  any,
  text,
  integer,
  real,
  reference,
}

class AttrCtrl<T extends Attr> extends NodeCtrl<T> {
  AttrCtrl({
    super.name = 'attribute',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class Attr extends NodeFractal {
  static final controller = AttrCtrl(
      extend: NodeFractal.controller,
      make: (d) => switch (d) {
            MP() => Attr.fromMap(
                d,
                setup: intToBits(d['setup'] ?? 0, bitLength: 8),
              ),
            _ => throw ('wrong'),
          },
      attributes: <Attr>[
        Attr(
          name: 'format',
          format: FormatF.integer,
        ),
        Attr(
          name: 'def',
          format: FormatF.text,
        ),
        Attr(
          name: 'setup',
          format: FormatF.integer,
        ),
      ]);

  @override
  get uis => ui;
  static var ui = <String>[];

  @override
  AttrCtrl get ctrl => controller;

  @override
  String get type => 'attribute';

  final FormatF format;
  final String def;
  final bool isImmutable;
  final bool isUnique;
  final bool isIndex;
  final bool isPrivate;
  final bool canNull;
  final bool skipCreate;

  List<bool> bits = [];

  Object fromString(String val) => switch (format) {
        FormatF.integer => int.tryParse(val) ?? 0,
        FormatF.real => double.tryParse(val) ?? 0.0,
        _ => val
      };

  String get formatStr => switch (format) {
        FormatF.text => "TEXT",
        FormatF.integer => "INTEGER",
        FormatF.real => "REAL",
        _ => "INTEGER",
      };

  String get sqlDefinition =>
      '"$name" $formatStr ${!canNull ? 'DEFAULT $_sqlDef ' : ''} ${isUnique ? 'UNIQUE' : ''} ${canNull ? ' ' : 'NOT '}NULL';

  String get _sqlDef => switch (format) {
        FormatF.text => "'$def'",
        FormatF.integer || FormatF.reference => '${int.tryParse(def) ?? 0}',
        FormatF.real => '${double.tryParse(def) ?? 0.0}',
        _ => "''",
      };

  @override
  String toString() => '$sqlDefinition ';

  //final List<String> options;

  Attr({
    required super.name,
    required this.format,
    this.isUnique = false,
    this.isIndex = false,
    this.isPrivate = false,
    this.canNull = false,
    this.isImmutable = false,
    this.skipCreate = false,
    //this.options = const [],
    this.def = '',
    super.d,
    super.kind = FKind.system,
    super.to,
  }) {
    //owner = null;
    //hash = Hashed.make(ctrl.hashData());
  }

  Attr.fromMap(
    super.d, {
    required List<bool> setup,
  })  : bits = intToBits(d['setup'] ?? 0),
        format = FormatF.values[d['format'] ?? 0],
        def = "${d['def'] ?? ''}",
        isImmutable = setup[0],
        isUnique = setup[1],
        isIndex = setup[2],
        isPrivate = setup[3],
        canNull = setup[4],
        skipCreate = setup[5],
        super.fromMap();

  @override
  Object? operator [](key) => switch (key) {
        'format' => format.index,
        'setup' => bitsToInt([
            isImmutable,
            isUnique,
            isIndex,
            isPrivate,
            canNull,
            skipCreate,
          ]),
        'def' => def,
        'ui' => super[key] ?? 'input',
        _ => super[key],
      };
}
