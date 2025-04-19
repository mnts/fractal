import 'package:fractal/index.dart';
import 'types.dart';

mixin FractalFS on HierarchyF {
  var fType = FileFractalType.unknown;

  @override
  //get image => isImageFile ? ImageF(localPath) : super.image;

  String localPath = '';
}
