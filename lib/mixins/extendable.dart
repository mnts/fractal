import '../models/index.dart';
import '../index.dart';

mixin ExtendableF on EventFractal {
  //final extensions = MapEvF<NodeFractal>();
  static final attr = Attr(
    name: 'extend',
    format: FormatF.reference,
    canNull: true,
    isIndex: true,
    isImmutable: true,
  );

  NodeFractal? extend;
  setExtendable(MP m) async {
    /*
    if (await NetworkFractal.request(extHash) case NodeFractal ext) {
      await ext.ready;
      extend = ext;
      //m['type'] ??= extend!.type;
    }
    */
    if (m['extend'] case NodeFractal f) extend = f;

    if (extend != null) {
      listenExtended();
      //extend!.extensions.complete(hash, this);
      notifyListeners();

      //if (events != null) {
      extend!.preload();
    }
  }

  listenExtended() {
    extend?.addListener(() {
      notifyListeners();
    });
  }

  preloadExtend() async {
    await extend?.ready;
    await extend?.preload(type);
    return;
  }
}
