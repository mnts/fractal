import 'dart:async';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:fractal/fractal.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
export 'file/io.dart' if (dart.library.html) 'file/idb.dart';
import 'package:dart_bs58check/dart_bs58check.dart';

extension Uint8List4FileF on Uint8List {
  FileF get fractal => FileF.bytes(this);
}

extension FileF4Completer on Completer {
  completed() {
    if (!isCompleted) complete();
  }
}

class FileF {
  static bool isWeb = false;
  static var path = './';
  static bool isSecure = false;
  static String main = 'localhost';
  static String host = isSecure ? Uri.base.host : 'localhost:8800';
  static String wsUrl(String server) =>
      'ws${FileF.isSecure ? 's' : ''}://$server';

  static final cache = <String, Uint8List>{};

  //static final urlImage = urlFile;
  static var urlFile = (String hash) => Uri.parse("$http/uploads/$hash");

  static String get http => "http${isSecure ? 's' : ''}://$host";

  //static final dateFormat = DateFormat('MM-dd-yyyy kk:mm');
  static eat(Map<String, dynamic> m) {}

  static String hash(List<int> bytes) {
    final b = md5.convert(bytes).bytes;

    Uint8List h = Uint8List(4 + b.length);
    ByteData.view(h.buffer).setUint32(0, b.length);
    h.setRange(4, 4 + b.length, b);
    return bs58check.encode(h);
  }

  static final _map = <String, FileF>{};
  factory FileF(String name) {
    final file = _map[name] ??= FileF.fresh(
      name,
    );
    return file;
  }

  static final emptyBytes = Uint8List(0);
  late String fileName = name;

  final File file;
  var bytes = emptyBytes;
  factory FileF.bytes(Uint8List bytes) {
    final name = hash(bytes);
    final f = _map[name] ??= FileF.fresh(name);

    f.bytes = bytes;
    //f.initBytes();
    return f;
  }

  String name;
  FileF.fresh(this.name) : file = getFile(name);

  static getFile(String name) => name.isNotEmpty && name[0] == '/'
      ? File(name)
      : File(
          join(path, 'cache', name),
        );

  /*
  initBytes() async {
    if (!await file.exists()) {
      await store();
    }
  }
  */

  bool get isReady => bytes == emptyBytes;
  final stored = Completer();
  Future<bool> store() async {
    file.createSync(recursive: true);
    await file.writeAsBytes(bytes);
    stored.completed();
    return true;
  }

  String get url => urlFile(name).toString();

  final uploaded = Completer();
  static Future<String?> Function(FileF)? uploader;
  Future<int> upload() async {
    if (uploaded.isCompleted) return 200;

    final re = await Request('GET', urlFile(name)).send();
    if (re.statusCode == 200 || re.statusCode == 204) {
      uploaded.complete();
      return 200;
    }

    if (uploader != null) {
      final serverPath = await uploader!(this);
      if (serverPath != null) uploaded.complete();
      return 200;
    }

    var url = Uri.parse(
      "$http/upload",
    );

    // Create a MultipartRequest object to hold the file data
    var request = MultipartRequest('POST', url);

    request.files.add(MultipartFile.fromBytes(
      'file',
      bytes,
    ));

    try {
      final re = await request.send();
      //var responseBody = await response.stream.bytesToString();

      if (re.statusCode == 200) uploaded.complete();

      return re.statusCode;
    } catch (e) {
      print('failed to upload $name');
    }
    return 0;
  }

  //Completer<int>? publishing;
  Future<void> publish() async {
    await Future.wait([store(), upload()]);
    return;
  }

  Completer<void>? reading;
  read() {
    if (reading != null) return;
    reading ??= Completer();
    try {
      file.readAsBytes().then((value) {
        bytes = value;
        stored.completed();
        reading!.complete();
      }, onError: (error, stackTrace) {
        stored.completed();
        reading!.complete();
      });
    } catch (_) {
      stored.completed();
      reading!.complete();
    }
    //return bytes;
  }

  Completer<void>? loading;
  Future<void> load() async {
    read();
    if (reading != null) await reading!.future;
    if (loading != null) return loading!.future;
    if (bytes.isEmpty) {
      loading ??= Completer();
      try {
        bytes = await download(name);
        store();
      } catch (e) {
        print(e);
      }

      if (loading?.isCompleted == false) loading!.complete();
    }
    return;
  }

  static Future<Uint8List> download(String name) async {
    // Create a MultipartRequest object to hold the file data
    var request = Request('GET', urlFile(name));
    final re = await request.send();

    if (re.statusCode == 200 || re.statusCode == 204) {
      return re.stream.toBytes();
    }
    throw Exception('cant download $name');
  }
}
