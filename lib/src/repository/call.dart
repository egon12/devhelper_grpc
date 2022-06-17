import 'package:sqflite/sqflite.dart';

import '../call/call.dart';

class CallRepo {
  final Database db;

  static const String _tableName = 'calls';

  CallRepo({required this.db});

  Future<Iterable<CallPersistent>> all() async {
    var rows = await db.query(_tableName);
    return rows.map((r) => CallPersistent.fromMap(r));
  }

  Future<void> save(CallPersistent c) async {
    await db.insert(_tableName, c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(CallPersistent c) async {
    db.delete(_tableName, where: 'id = ?', whereArgs: [c.id]);
  }

  static const createQuery = '''
  CREATE TABLE $_tableName (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      host TEXT NOT NULL,
      port INT NOT NULL,
      pkg TEXT NOT NULL,
      service TEXT NOT NULL,
      method TEXT NOT NULL,
      reqProto BLOB NOT NULL,
      resProto BLOB NOT NULL,
      req TEXT NOT NULL,
      res TEXT 
  )''';

  static const dropQuery = 'DROP TABLE $_tableName';
}
