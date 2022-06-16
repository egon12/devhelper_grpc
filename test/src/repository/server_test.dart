import 'package:devhelper_grpc/src/repository/db.dart';
import 'package:devhelper_grpc/src/repository/server.dart';
import 'package:devhelper_grpc/src/server/server.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test save', () async {
    var db = await getDB();
    var r = ServerRepo(db: db);

    var s1 = Server('localhost', 50051);
    var s2 = Server('localhost', 50052, true);
    var s3 = Server('somehostname.com.rd', 50053, false);

    await r.save(s1);
    await r.save(s2);
    await r.save(s3);

    var servers = await r.all();

    var list = servers.toList();
    expect(list[0], s1);
    expect(list[1], s2);
    expect(list[2], s3);

    r.remove(s1);
    r.remove(s2);

    servers = await r.all();

    list = servers.toList();
    expect(list[0], s3);

    r.remove(s3);
  });
}
