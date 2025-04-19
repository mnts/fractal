import 'package:sqlite3/wasm.dart';
import 'abstract.dart';
import 'sqlite.dart';

class WebFDB extends SqliteFDB {
  late CommonDatabase _db;
  WebFDB(super.name);

  @override
  connect() async {
    /*
    _db = await AsyncDatabase.open(
      join(FileF.path, "$name.db"),
    );
    */

    final sqlite3 = await WasmSqlite3.loadFromUrl(
      Uri.parse('sqlite3.wasm'),
      //environment: SqliteEnvironment(fileSystem: fs),
    );
    final fs = await IndexedDbFileSystem.open(
      dbName: name,
    );

    sqlite3.registerVirtualFileSystem(
      fs,
      makeDefault: true,
    );

    _db = sqlite3.open(
      name,
    );

    return true;
  }

  @override
  query(String sql, [List<Object?> parameters = const []]) async {
    try {
      _db.execute(sql, parameters);
      return true;
    } catch (err) {
      return false;
    }
    //_db.writeTransaction((tx) => null)
  }

  @override
  store(params) async {
    var _lastId = 0;
    try {
      _db.execute('BEGIN;');
      final st = params.statements.removeAt(0);
      _db.execute(st.sql, st.parameters);
      //_lastId = _db.lastInsertRowId;
      for (var st in params.statements) {
        _db.execute(st.sql, st.parameters);
      }
      _db.execute("COMMIT;");
    } catch (err) {
      print(err);
      _db.execute("END;");
      return false;
    }
    return true;
  }

  @override
  select(String sql, [List<Object?> parameters = const []]) {
    return Future.value(
      _db.select(sql, parameters),
    );
  }

  //Future<int> get lastInsertI => Future.value(_lastId);
}

FDBA constructDb(String name) {
  print('construct WEB Db');
  return WebFDB(name);
}

/*
Future<CommonDatabase> openDBSync(
    AsyncDatabaseCommand cmd, ReceivePort ourReceivePort) async {
  OpenDatabaseParams params = cmd.body;

  DBF.isWeb = true;
  final sqlite3 = await WasmSqlite3.loadFromUrl(
    Uri.parse('sqlite3.wasm'),
    //environment: SqliteEnvironment(fileSystem: fs),
  );
  final fs = await IndexedDbFileSystem.open(
    dbName: 'fractal',
  );
  sqlite3.registerVirtualFileSystem(
    fs,
    makeDefault: true,
  );

  CommonDatabase db = sqlite3.open(
    params.filename,
    vfs: params.vfs,
    mode: params.mode,
    uri: params.uri,
    mutex: params.mutex,
  );

  cmd.sendPort.send(AsyncDatabaseCommand(cmd.type, ourReceivePort.sendPort));
  return db;
}
*/
