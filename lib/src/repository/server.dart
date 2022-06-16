import 'package:sqflite/sqflite.dart';

import '../server/server.dart';

class ServerRepo {
  final Database db;

  static const String _tableName = 'server';

  ServerRepo({required this.db});

  Future<Iterable<Server>> all() async {
    var rows = await db.query(_tableName);
    return rows.map((r) {
      var host = r['host'] as String;
      var port = r['port'] as int;
      var useTLS = r['use_tls'] == 'true';

      return Server(host, port, useTLS);
    });
  }

  Future<void> save(Server server) async {
    var values = {
      'url': server.toString(),
      'host': server.host,
      'port': server.port,
      'use_tls': server.useTLS.toString(),
    };
    await db.insert(_tableName, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(Server server) async {
    db.delete(_tableName, where: 'url = ?', whereArgs: [server.toString()]);
  }

  static const createQuery = '''
  CREATE TABLE $_tableName (
    url TEXT PRIMARY KEY, 
    host TEXT NOT NULL, 
    port INT NOT NULL, 
    use_tls BOOLEAN NOT NULL
  )''';

  static const dropQuery = 'DROP TABLE $_tableName';
}
