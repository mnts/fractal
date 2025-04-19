import 'package:fractal/types/mp.dart';
import 'package:fractal/access/abstract.dart';

class SqliteFDB extends FDBA {
  SqliteFDB(super.name);

  get tables => select('''
      SELECT name FROM sqlite_schema WHERE 
      type ='table' AND 
      name NOT LIKE 'sqlite_%';
    ''');

  @override
  tableInfo(name) => select('''
      PRAGMA table_info("$name")
    ''');

  tableIndexes(name) => select('''
      PRAGMA index_list("$name")
    ''');

  @override
  Future<bool> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<bool> query(String sql, [List<Object?> parameters = const []]) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  Future<List<MP>> select(String sql, [List<Object?> parameters = const []]) {
    // TODO: implement select
    throw UnimplementedError();
  }

  @override
  Future<bool> store(FTransactionParams transaction) {
    // TODO: implement store
    throw UnimplementedError();
  }
}
