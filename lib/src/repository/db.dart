import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'server.dart';

Future<Database> getDB() {
  DatabaseFactory databaseFactory;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    return databaseFactory.openDatabase(
      'devhelper_grpc.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
      ),
    );
  }

  return openDatabase(
    'devhelper_grpc.db',
    version: 1,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    onDowngrade: onDowngrade,
  );
}

void onCreate(Database db, int version) async {
  var batch = db.batch();

  batch.execute(ServerRepo.createQuery);

  batch.commit();
}

void onUpgrade(Database db, int oldVersion, int newVersion) async {}

void onDowngrade(Database db, int oldVersion, int newVersion) async {
  var batch = db.batch();
  batch.execute(ServerRepo.dropQuery);
  batch.commit();
}
