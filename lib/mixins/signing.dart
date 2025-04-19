import '../index.dart';

mixin SigningMix on NodeFractal {
  static final attributes = [
    Attr(
      name: 'private_key',
      format: FormatF.text,
      isPrivate: true,
    ),
    Attr(
      name: 'public_key',
      format: FormatF.text,
    ),
  ];

  static final storage = <String, SigningMix>{};

  late KeyPair keyPair;
  _construct() {
    //map[keyPair.privateKey] = this;
  }

  static KeyPair signing() {
    return RandomKeyPairGenerator().generate();
    //_construct();
  }

  static KeyPair signingFromMap(MP d) {
    return d['public_key'] != null
        ? KeyPair(
            publicKey: d['public_key'],
            privateKey: d['private_key'],
          )
        : RandomKeyPairGenerator().generate();
  }

  MP get signingMap => {
        'public_key': keyPair.publicKey,
        'private_key': keyPair.privateKey,
      };

  static final signer = Signer();
  String sign(String text) => signer.sign(
        privateKey: keyPair.privateKey,
        message: text,
      );
}
