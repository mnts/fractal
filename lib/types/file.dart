import 'dart:async';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:fractal/fractal.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'dart:io' if (dart.library.html) 'file_idb.dart';
export 'file_io.dart' if (dart.library.html) 'file_idb.dart';
import 'dart:typed_data';
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
  static var path = './';
  static bool isSecure = false;
  static String main = 'localhost';
  static String host = isSecure ? Uri.base.host : 'localhost:8800';
  static String wsUrl(String server) =>
      'ws${FileF.isSecure ? 's' : ''}://$server';

  static final cache = <String, Uint8List>{};

  static final urlImage = urlFile;
  static String urlFile(String hash) => "$http/uploads/$hash";

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

  final File file;
  var bytes = emptyBytes;
  factory FileF.bytes(Uint8List bytes) {
    final name = hash(bytes);
    final file = _map[name] ??= FileF.fresh(name);
    file
      ..bytes = bytes
      ..init()
      ..store();
    return file;
  }

  String name;
  FileF.fresh(this.name)
      : file = name[0] == '/'
            ? File(name)
            : File(
                join(path, 'cache', name),
              ) {
    reload();
  }

  init() async {}

  bool get isReady => bytes == emptyBytes;
  final stored = Completer();
  FutureOr<bool> store() async {
    if (await file.exists()) return true;
    file.createSync(recursive: true);
    await file.writeAsBytes(bytes);
    stored.completed();
    return true;
  }

  String get url => urlImage(name);

  static Future<ByteStream> download(String name) async {
    var url = Uri.parse(
      "$http/uploads/$name",
    );

    // Create a MultipartRequest object to hold the file data
    var request = Request('GET', url);
    final re = await request.send();

    return re.stream;
  }

  final uploaded = Completer();
  Future<int> upload() async {
    if (uploaded.isCompleted) return 200;

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

  final published = Completer<int>();
  Future<int> publish() async {
    if (published.isCompleted) return published.future;

    await store();

    upload().then((status) {
      if (status == 200) published.complete(unixSeconds);
    });

    return unixSeconds;
  }

  reload() {
    try {
      file.readAsBytes().then((value) {
        bytes = value;
        stored.completed();
      }, onError: (error, stackTrace) {
        stored.completed();
      });
    } catch (_) {
      stored.completed();
    }
    //return bytes;
  }

  Completer? loading;
  Future<Uint8List> load() async {
    await stored.future;
    await loading?.future;
    if (bytes.isEmpty) {
      loading ??= Completer();
      final stream = await download(name);
      bytes = await stream.toBytes();
      await store();
      if (loading?.isCompleted == false) loading!.complete();
    }
    return bytes;
  }
}
