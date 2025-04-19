import 'dart:async';
import 'access/abstract.dart';
import 'index.dart';
export 'access/unsupported.dart'
    if (dart.library.ffi) 'access/native.dart'
    if (dart.library.html) 'access/web.dart';

class DBF {
  static late final DBF main;
  static bool isWeb = false;
  FDBA db;
  DBF(this.db) {
    //db.execute('END;');
  }

  Future<bool> init() async {
    await db.connect();

    //db = SqliteDatabase(path: 'test.db');

    //await db.query('PRAGMA foreign_keys=ON;');

    //clear();
    if (tables.where((t) => t.name == 'variables').isEmpty) {
      await initVars();
    }

    for (var row in await db.tables) {
      tables.add(
        TableF(
          name: row.values.first as String,
        ),
      );
    }
    return true;
  }

  //static late CommonSqlite3 sqlite;
  static FutureOr<bool> initiate(FDBA fdb) async {
    main = DBF(fdb);
    await main.init();
    return true;
  }

  Future<void> setVar(String key, dynamic val) async {
    await db.query(
      'INSERT INTO "variables" VALUES (?,?,?)',
      [
        key,
        (val is String) ? val : '',
        (val is int) ? val : 0,
      ],
    );
    final frac = StoredFrac.map[key];
    frac?.value = val;
    frac?.notifyListeners();
  }

  final tables = <TableF>[];

  Future<String?> getVar(String key) async {
    final re = await db.select(
      'SELECT value, numb FROM "variables" WHERE name=?',
      [key],
    );
    if (re.isEmpty) return null;
    final str = re.first['value'] as String;
    return (str.isEmpty) ? '${re.first['numb']}' : re.first['value'];
  }

  clear() async {
    db.query('''
      PRAGMA writable_schema = 1;
      DELETE FROM sqlite_master;
      PRAGMA writable_schema = 0;
      VACUUM;
      PRAGMA integrity_check;
    ''');
  }

  Future<TableF> initVars() async {
    await db.query("""
      CREATE TABLE IF NOT EXISTS "variables" 
      (name TEXT PRIMARY KEY, value TEXT, numb INTEGER);
    """);
    return TableF(name: 'vars');
  }
}
