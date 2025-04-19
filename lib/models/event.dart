import 'dart:async';
import 'package:intl/intl.dart';

import '../index.dart';

class EventFractal extends Fractal with Hashed, Consumable {
  static final controller = EventsCtrl(
    extend: Fractal.controller,
    make: (d) async {
      return switch (d) {
        MP() => EventFractal.fromMap(d),
        null || Object() => throw ('wrong event type')
      };
    },
    attributes: [
      Attr(
        name: 'hash',
        format: FormatF.text,
        isIndex: true,
        isUnique: true,
      ),
      Attr(
        name: 'owner',
        format: FormatF.reference,
        isIndex: true,
        canNull: true,
        isImmutable: true,
      ),
      Attr(
        name: 'pubkey',
        format: FormatF.text,
        isImmutable: true,
      ),
      Attr(
        name: 'created_at',
        format: FormatF.integer,
        isImmutable: true,
        isIndex: true,
      ),
      Attr(
        name: 'content',
        format: FormatF.text,
        def: '',
        isImmutable: true,
      ),
      ...Consumable.attrs,
      Attr(
        name: 'sig',
        format: FormatF.text,
      ),
      Attr(
        name: 'sync_at',
        format: FormatF.integer,
      ),
    ],
  );

  static final storage = MapEvF();

  @override
  EventsCtrl get ctrl => controller;

  bool get dontStore => false;

  late final String pubkey;

  int createdAt = 0;

  final String content;
  late final List contents = RefF.parseContent(content);

  Future<MP> throughContent(MP map) async {
    MP mp = {};
    for (var c in contents) {
      if (c case ThingF thing) {
        final telling = thing.tell(map);
        final r = await telling;
        if (r is MP) {
          mp.addAll(r);
        }
      }
    }
    return mp;
  }

  @override
  Future tell(m, {LinkFractal? link}) async {
    final r = switch (m) {
      SparkF spark => spark.re(
          await throughContent(spark.map),
        ),
      _ => null,
    };
    return r;
  }

  DateTime get createdDate =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  int syncAt;
  DateTime get syncDate => DateTime.fromMillisecondsSinceEpoch(syncAt * 1000);

  String sig = '';

  String get display => content.isEmpty ? hash : content;

  @override
  toString() => hash;

  Iterable<String> get uis => [];

  @override
  String get path => '/-$hash';

  String doHash() {
    hash = Hashed.make(
      ctrl.hashData(
        toMap(),
      ),
    );
    return hash;
  }

  static bool isHash(String h) => h.length < 52 && h.length >= 48;

  move() {}

  //@mustCallSuper
  Future<bool> construct() async {
    if (this is! Attr) ctrl.input(this);
    _completer.complete(true);
    return true;
  }

  Future<bool> constructFromMap(MP m) async {
    return construct();
  }

  _construct() {
    if (to != null) {
      consumable();
    }
  }

  @override
  void consume(f) {
    if (f case EventFractal evf
        when f.kind == FKind.system && evf.content == 'remove') {
      ctrl.list.removeWhere((f) => f == this);
      EventFractal.storage.remove(hash);
      for (var c in CatalogFractal.controller.list) {
        if (c.list.remove(this)) {
          c.notify(this);
        }
      }
      ctrl.query("DELETE FROM fractal WHERE id = ?;", [id]);
      notifyListeners();
    }
    //super.consume(event);
  }

  @override
  get key => hash;

  EventFractal({
    super.id,
    String hash = '',
    String? pubkey,
    int? createdAt,
    this.content = '',
    this.syncAt = 0,
    NodeFractal? owner,
    this.sig = '',
    EventFractal? to,
    super.kind,
  }) {
    super.to = to;
    if (this is! Attr /*&& this is! ClientFractal*/) {
      this.owner = owner ?? UserFractal.active.value ?? DeviceFractal.my;
    }

    syncAt = to?.decideSync ?? 1;

    this.hash = hash;
    this.pubkey = pubkey ?? _myKeyPair?.publicKey ?? '';
    if (createdAt == null) this.createdAt = unixSeconds;

    _construct();
    //ownerC.complete(owner);
    construct();
  }

  /*
  late final events = CatalogFractal(
    filter: {'to': hash},
    source: eventsSource,
  )..createdAt = 2;
*/

  FileF? get file => kind == FKind.file ? FileF(content) : null;

  bool get deleteOlder => false;

  EventsCtrl get eventsSource => WriterFractal.controller;

  @override
  preload([type]) async {
    await ready;
    if (hash.isEmpty) return 0;

    return 1;
  }

  KeyPair? get _myKeyPair {
    return UserFractal.active.value?.keyPair;
  }

  bool get own => _myKeyPair != null && pubkey == _myKeyPair!.publicKey;
  //bool get own => active.value == owner;

  NodeFractal? owner;

  refresh() {}

  //final ownerC = Completer<UserFractal?>();

  bool get sharable => true;

  /*
  factory EventFractal.get(MP m) {
    final ctrl = FractalCtrl.map[m['name']] as EventsCtrl;
    final hash = Hashed.make(ctrl.hashData(m));
    return EventFractal.storage[hash] ?? EventFractal.fromMap(m);
  }
  */

  int get decideSync => syncAt > 0 ? 1 : 0;

  EventFractal.fromMap(MP d)
      : pubkey = d['pubkey'] ?? '',
        createdAt = d['created_at'] ?? unixSeconds,
        content = '${d['content'] ?? ''}',
        syncAt = d['sync_at'] ??
            switch (d['to']) {
              EventFractal ev => ev.decideSync,
              _ => 1,
            },
        sig = d['sig'] ?? '',
        owner = d['owner'],
        super.fromMap(d) {
    to = d['to'];
    hash = d['hash'] ?? '';

    if (d['shared_with'] case List shared) {
      for (var x in shared) {
        switch (x) {
          case String h:
            final device = EventFractal.storage[h] as DeviceFractal;
            sharedWith.add(device);
          case DeviceFractal device:
            sharedWith.add(device);
        }
      }
    }

    /*
    final nHash = makeHash();
    if (hash != nHash) {
      //throw throw Exception('hash $hash != $nHash of $type');
      isValid = false;
    }
    */
    _construct();
    constructFromMap(d).then((b) {
      if (hash.isNotEmpty) {
        complete();
      }
    });
  }

  @override
  store([m]) async {
    MP mp = {
      for (var a in ctrl.allAttributes.values)
        if (this[a.name] case Object v)
          a.name: switch (v) {
            String h when a.format == FormatF.reference => storage[h]?.id,
            EventFractal ev when a.format == FormatF.integer => ev.id,
            _ => v,
          },
      ...?m,
    };

    final id = await super.store(mp);
    if (id == 0) return 0;
    print('stored #$hash $hashCode');
    if (to?.id case int into when deleteOlder) {
      ctrl.query("""
        DELETE FROM fractal
        WHERE id IN (
          SELECT $type.id
          FROM $type
          INNER JOIN event
          ON event.id=$type.id
          WHERE event.created_at < ?
          AND event."to" = ?
        );
      """, [createdAt, into]);
    }
    return id;
  }

  final _completer = Completer<bool>();
  Future<bool> get ready => _completer.future;

  @override
  delete() async {
    await EventFractal(
      content: 'remove',
      to: this,
      kind: FKind.system,
    ).synch();
  }

  bool isValid = true;

  /*
  static final listeners = <String, Function(EventFractal)>{};
  static listen(String name, Function(EventFractal) cb) {
    listeners[name] = (cb);
  }

  static unListen(String name) {
    listeners.remove(name);
  }
  */

  String get url => hash;

  int idEvent = 0;
  @override
  synch() async {
    complete();
    //distribute();
    if (!(await ready)) throw ('Item not ready');

    //if (kind == FKind.tmp) return;
    await super.synch();
  }

  setSynched() {
    syncAt = unixSeconds;

    //update field in db
    /*
    query(
      'UPDATE event SET sync_at = ? WHERE hash = ?',
      [syncAt, hash],
    );
    */
  }

  /*
  distribute() {
    for (var entry in map.values) {
      if (sharedWith.contains(entry.hash)) continue;
      sharedWith.add(entry.hash);
    }
  }
  */

  FutureOr<EventFractal> clone(MP m) {
    final map = {
      for (var a in ctrl.attributes
          .where((a) => !m.containsKey(a.name) && !a.isPrivate))
        a.name: this[a.name],
    };

    return ctrl.put(MakeF(map));
  }

  final sharedWith = <DeviceFractal>[];
  void complete() {
    if (hash.isEmpty) doHash();
    storage.complete(hash, this);

    //sig = UserFractal.active.value?.sign(hash) ?? '';
    //ctrl.consume(this);
  }

  @override
  MP toMap() => {
        for (var a in ctrl.allAttributes.values) a.name: this[a.name],
        ...super.toMap(),
      };

  @override
  operator [](key) => switch (key) {
        'to' => to?.key ?? '',
        'hash' => hash,
        'sig' => sig,
        'pubkey' => pubkey,
        'content' => content,
        'owner' => owner?.hash,
        'sync_at' => syncAt,
        'created_at' => createdAt,
        _ => super[key],
      };

  @override
  represent(key) => switch (key) {
        'sync_at' => DateFormat('dd MMM yyyy hh:mm').format(syncDate),
        'created_at' => DateFormat('dd MMM yyyy hh:mm').format(createdDate),
        _ => super.represent(key),
      };
}
