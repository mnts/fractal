import 'package:fractal/types/mp.dart';

abstract class FDBA {
  String name;
  FDBA(this.name);
  Future<bool> connect();
  int lastId = 0;
  Future<bool> store(FTransactionParams transaction);
  Future<bool> query(String sql, [List<Object?> parameters = const []]);
  Future<List<MP>> select(String sql, [List<Object?> parameters = const []]);
  Future<List<MP>> get tables;
  Future<List<MP>> tableInfo(String name);
  Future<List<MP>> tableIndexes(String name);
}

class FStatementParams {
  final String sql;
  final List<Object?> parameters;

  const FStatementParams(this.sql, this.parameters);
}

class FTransactionParams {
  final List<FStatementParams> statements;

  const FTransactionParams(this.statements);
}
