import 'dart:convert';
import 'dart:typed_data';
import 'fractal.dart';
import 'types.dart';

extension FileFractalIO on FileFractal {
  static const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

  String get ext => name.split('.').last.toLowerCase();
  bool get isImageFile => imageExts.contains(ext);

  String? get fsUI => switch (fType) {
        FileFractalType.file || FileFractalType.unknown => switch (ext) {
            'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'webp' => 'image',
            'txt' ||
            'dart' ||
            'js' ||
            'css' ||
            'html' ||
            'json' ||
            'yaml' ||
            'yml' ||
            'md' =>
              'text',
            _ => 'file',
          },
        FileFractalType.directory => 'tiles',
        _ => null,
      };

  initFile() async {
    switch (ext) {
      case 'json':
        try {
          final b = await fs.readAsBytes();
          if (b == null) return;
          final json = jsonDecode(
            utf8.decode(b),
          );
          d = switch (json) {
            Map m => {...m},
            List l => {'list': l},
            _ => {},
          };
        } catch (_) {}
    }
    return;
  }

  write(Uint8List bytes) {
    fs
      ..createSync()
      ..writeAsBytes(bytes);
    notifyListeners();
  }
}
