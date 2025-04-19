import '../index.dart';
import '../models/index.dart';
import 'hashed.dart';

mixin Consumable on Fractal {
  static final attrs = [
    Attr(
      name: 'to',
      format: FormatF.reference,
      isImmutable: true,
      isIndex: true,
    ),
  ];
  Consumable? to;

  consumable() async {
    if (to == null) return;
    provide(to!);
    to!.consume(this);
  }

  void consume(Consumable f) {
    //super.consume(event);
  }

  provide(Consumable into) {
    /*
    print('provide');
    print(into);
    */
  }

  CatalogFractal? events;
}
