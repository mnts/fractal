import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dart_bs58check/dart_bs58check.dart';
import '../index.dart';

class UserCtrl<T extends UserFractal> extends NodeCtrl<T> {
  UserCtrl({
    super.name = 'user',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class UserFractal extends NodeFractal with SigningMix {
  static final active = Frac<UserFractal?>(null);

  static final controller = UserCtrl(
    make: (d) => UserFractal.fromMap(d),
    extend: NodeFractal.controller,
    attributes: [
      Attr(
        name: 'eth',
        format: FormatF.text,
        canNull: true,
      ),
      Attr(
        name: 'pass',
        format: FormatF.text,
        isPrivate: true,
      ),
      Attr(
        name: 'email',
        format: FormatF.text,
        isIndex: true,
        isImmutable: false,
        canNull: true,
      ),
      Attr(
        name: 'domain',
        format: FormatF.text,
        isIndex: true,
        isImmutable: false,
        canNull: true,
      ),
      ...SigningMix.attributes,
    ],
  );

  static Future init() async {
    await controller.init();

    activeHash = await DBF.main.getVar('active') ?? '';
    if (activeHash.isNotEmpty) {
      NetworkFractal.request(activeHash);
    }
  }

  @override
  UserCtrl get ctrl => controller;

  @override
  String get path => '/@$name';

  String? email;
  String? domain;
  String? eth;
  String? pass;

  static final flow = TypeFilter<UserFractal>(
    NodeFractal.flow,
  );

  late final KeyPair keyPair;

  @override
  UserFractal({
    this.eth,
    super.to,
    super.keyPair,
    super.extend,
    String? password,
    required super.name,
    this.email,
    this.domain,
    super.createdAt = 0,
  }) : keyPair = SigningMix.signing() {
    if (password != null) {
      pass = makePass(password);
    }
  }

  bool auth(String password) {
    return makePass(password) == pass;
  }

  static String activeHash = '';

  UserFractal.fromMap(MP d)
      : eth = d['eth'],
        pass = d['pass'],
        email = d['email'],
        domain = d['domain'],
        keyPair = SigningMix.signingFromMap(d),
        super.fromMap(d) {
    if (d['password'] case String password) {
      pass = makePass(password);
    }

    if (activeHash == hash) active.value = this;
  }

  @override
  Object? operator [](key) => switch (key) {
        'eth' => eth,
        'email' => email,
        'domain' => domain,
        'pass' => pass ?? '',
        _ => super[key],
      };

  static String makePass(String word) {
    final b = md5.convert(utf8.encode(word)).bytes;

    return bs58check.encode(
      Uint8List.fromList(b),
    );
  }

  static activate(UserFractal user) {
    UserFractal.active.value = user;
    DBF.main.setVar('active', user.hash);
  }

  static logOut() {
    UserFractal.active.value = null;
    DBF.main.setVar('active', '');
  }
}
