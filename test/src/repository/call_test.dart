import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'package:devhelper_grpc/src/call/call.dart';
import 'package:devhelper_grpc/src/repository/call.dart';
import 'package:devhelper_grpc/src/repository/db.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test save', () async {
    var db = await getTestDB();
    var c = CallRepo(db: db);

    var callPersistence = CallPersistent(
      name: 'name',
      host: 'host',
      port: 50051,
      pkg: 'mypkg',
      service: 'service',
      method: 'handle',
      reqProto: DescriptorProto(),
      resProto: DescriptorProto(),
    );

    await c.save(callPersistence);

    var got = await c.all();

    expect(got.first.id, callPersistence.id);

    c.remove(callPersistence);

    for (var element in got) {
      await c.remove(element);
    }

    got = await c.all();
    expect(got.length, 0);
  });
}
