import 'package:devhelper_grpc/src/refelction_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devhelper_grpc/src/dynamic_message.dart';
import 'dart:async';
import 'package:grpc/grpc.dart';

void main() {
  test('test reflect', () async {
    final c = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    final sc = ReflectionClient(c);
    final services = await sc.services();

    expect(services, [
      'grpc.reflection.v1alpha.ServerReflection',
      'pkg.DynamicPage',
      'pkg.RechargeApp'
    ]);

    final methods = await sc.methods(services.toList()[1]);

    final method = methods[0];

    final inputDP = await sc.message(method.inputType.substring(1));
    final fdp = await sc.fdp(method.inputType.substring(1));
    final outputDP = await sc.message(method.outputType.substring(1));

    final dm = DynamicMessage.fromDescriptor(inputDP, fdp.package);
    final odm = DynamicMessage.fromDescriptor(outputDP, fdp.package);

    dm.setString(1, "hallo");

    final cm = ClientMethod(
      "/" + services[1] + "/" + method.name,
      (DynamicMessage dm) => dm.writeToBuffer(),
      (List<int> value) => odm.fromBuffer(value),
    );

    final call = c.createCall<DynamicMessage, DynamicMessage>(
        cm, Stream.value(dm), CallOptions());

    final res = await call.response.first;

    expect(outputDP.field.first.name, 'content');
    expect(res.get('content'), 'hallo');
    expect(res.toProto3Json(), {'content': 'hallo'});
  }, skip: 'need server with reflection');
}
