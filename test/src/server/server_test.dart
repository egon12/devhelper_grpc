import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/server/server.dart';

void main() {
  test('test server', () async {
    var s = Server('localhost', 50051);
    var r = s.reflection;

    var services = await r.services();
    expect(services[0], 'grpc.health.v1.Health');
  }, skip: 'need grpc server');
}
