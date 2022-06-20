import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/proto/hello.pbgrpc.dart';
import 'package:devhelper_grpc/proto/hello.pb.dart' as pb;
import 'package:grpc/grpc.dart';

void main() {
  test('hallo', () async {
    await listen();
    expect('hallo', 'hallo');
    final msg = await conn();
    expect(msg, 'hello Egon');
  });
}

class HelloImpl extends HelloServiceBase {
  @override
  Future<pb.Response> hello(ServiceCall call, Request req) async {
    return pb.Response(
      message: "hello " + req.name,
    );
  }
}

Future<void> listen() async {
  final server = Server([HelloImpl()], const <Interceptor>[], CodecRegistry());

  await server.serve(port: 50053);
}

Future<String> conn() async {
  final c = ClientChannel(
    'localhost',
    port: 50053,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(),
    ),
  );

  final hc = HelloClient(c);

  final res = await hc.hello(Request(name: 'Egon'));
  return res.message;
}
