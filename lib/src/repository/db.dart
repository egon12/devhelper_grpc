import 'dart:io';

import 'package:devhelper_grpc/src/repository/call.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'server.dart';

Future<Database> getDB() {
  String dbFilename = 'devhelper_grpc.db';
  return getDBWithFilename(dbFilename);
}

Future<Database> getTestDB() {
  String dbFilename = 'devhelper_grpc_test.db';
  return getDBWithFilename(dbFilename);
}

Future<Database> getDBWithFilename(String dbFilename) {
  DatabaseFactory databaseFactory;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    return databaseFactory.openDatabase(
      dbFilename,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
      ),
    );
  }

  return openDatabase(
    dbFilename,
    version: 1,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    onDowngrade: onDowngrade,
  );
}

void onCreate(Database db, int version) async {
  var batch = db.batch();

  batch.execute(ServerRepo.createQuery);
  batch.execute(CallRepo.createQuery);

  batch.commit();
}

void onUpgrade(Database db, int oldVersion, int newVersion) async {}

void onDowngrade(Database db, int oldVersion, int newVersion) async {
  var batch = db.batch();
  batch.execute(ServerRepo.dropQuery);
  batch.execute(CallRepo.dropQuery);
  batch.commit();
}
