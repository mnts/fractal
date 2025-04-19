import 'package:color/color.dart';
import 'package:fractal/types/image.dart';

class FractalSkin {
  Color white = const Color.rgb(250, 250, 250);
  Color black = const Color.rgb(5, 5, 5);

  ImageF? icon;
  Color color;
  Color extraColor;
  FractalSkin({
    this.icon,
    this.color = const Color.rgb(255, 17, 11),
    this.extraColor = const Color.rgb(255, 157, 11),
  });
}
