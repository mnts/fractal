import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:fractal/types/mp.dart';

import 'abstract.dart';

class PostgresFDBA extends FDBA {
  final Endpoint endpoint;
  late Connection _db;

  PostgresFDBA(
    super.name, {
    String host = 'localhost',
    int port = 5432,
    String? username,
    String? password,
  }) : endpoint = Endpoint(
          host: host,
          port: port,
          database: name,
          username: username,
          password: password,
        );

  @override
  Future<bool> connect() async {
    try {
      _db = await Connection.open(endpoint);
    } catch (e) {
      print('Error connecting to PostgreSQL: $e');
      return false;
    }

    try {
      lastId = (await _db.execute(
            'SELECT MAX(id) as mid FROM fractal',
          ))
              .first
              .first as int? ??
          0;
    } catch (e) {}

    return true;
  }

  @override
  get tables => select('''
    SELECT tablename As name
    FROM pg_tables 
    WHERE schemaname = 'public'
  ''');

  @override
  tableInfo(name) => select('''
        SELECT column_name as name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_name = ?
      ''', [name]);

  @override
  tableIndexes(name) => select('''
        SELECT indexname as name, indexdef
        FROM pg_indexes
        WHERE tablename = ?
    ''', [name]);

  var storing = <Future>[];
  @override
  store(FTransactionParams transaction) async {
    bool ok = false;
    Future? fu;
    await Future.wait(storing);
    try {
      fu = _db.runTx((tx) async {
        for (final statement in transaction.statements) {
          final result = await tx.execute(
            Sql.indexed(statement.sql, substitution: '?'),
            parameters: statement.parameters,
          );
          if (statement.sql.toLowerCase().startsWith('insert')) {
            // Very basic last insert id handling, adjust as needed.
            if (result.isNotEmpty && result.first.isNotEmpty) {
              if (result.first.first is int) {
                //_lastInsertId = result.first.first as int;
              }
            }
          }
        }
      });
      storing.add(fu);
      await fu;
      ok = true;
    } catch (e) {
      print('Error executing transaction: $e');
      print(transaction.statements
          .map((st) => '${st.parameters}\n${st.sql}')
          .join('\n'));
      ok = false;
    }

    storing.remove(fu);
    return ok;
  }

  @override
  Future<bool> query(String sql, [List<Object?> parameters = const []]) async {
    try {
      await Future.wait(storing);
      await _db.execute(
        Sql.indexed(sql, substitution: '?'),
        parameters: parameters,
      );
      return true;
    } catch (e) {
      print(parameters);
      print(sql);
      print('Error executing query: $e');
      return false;
    }
  }

  @override
  Future<List<MP>> select(String sql,
      [List<Object?> parameters = const []]) async {
    try {
      await Future.wait(storing);
      final results = await _db.execute(
        Sql.indexed(sql, substitution: '?'),
        parameters: parameters,
      );
      return results.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      print('Error executing select: $e');
      print(sql);
      return [];
    }
  }
}

FDBA constructPDB(String name) {
  return PostgresFDBA(name);
}
