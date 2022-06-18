import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:devhelper_grpc/src/dynamic_message/dynamic_message.dart';
import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'package:devhelper_grpc/proto/hello.pb.dart';

void main() {
  test('play with dynamic message', () {
    var dpJson =
        '{"1":"Response","2":[{"1":"message","3":1,"5":9,"6":"string"},{"1":"count","3":2,"5":3,"6":"int64"}]}';
    var dp = DescriptorProto.fromJson(dpJson);

    var dm = DynamicMessage.fromDescriptor(dp, '');
    dm.set('message', 'this is message');
    dm.set('count', Int64(3288172));

    var r = Response(message: 'this is message', count: Int64(3288172));

    expect(dm.writeToBuffer(), r.writeToBuffer());
  });

  test('mergeFromProto3Json', () {
    var dpJson =
        '{"1":"Response","2":[{"1":"message","3":1,"5":9,"6":"string"},{"1":"count","3":2,"5":3,"6":"int64"}]}';
    var dp = DescriptorProto.fromJson(dpJson);

    var dm = DynamicMessage.fromDescriptor(dp, '');
    var input = '{"message":"this is message","count":3288172}';
    var obj = jsonDecode(input);

    dm.mergeFromProto3Json(obj);

    var r = Response(message: 'this is message', count: Int64(3288172));
    expect(dm.writeToBuffer(), r.writeToBuffer());
  });

  test('generateEditableJson', () {
    var dpJson =
        '{"1":"Response","2":[{"1":"message","3":1,"5":9,"6":"string"},{"1":"count","3":2,"5":3,"6":"int64"}]}';
    var dp = DescriptorProto.fromJson(dpJson);
    var dm = DynamicMessage.fromDescriptor(dp, '');
    dm.set('count', Int64(0));

    var res = dm.generateEditableJson();
    var want = '''{
  "message": "",
  "count": "0"
}''';
    expect(res, want);
  });

  test('testing dynamic message with grpc.health.v1', () {
    var dpJson =
        '{"1":"HealthCheckResponse","2":[{"1":"status","3":1,"4":1,"5":14,"6":".grpc.health.v1.HealthCheckResponse.ServingStatus","10":"status"}],"4":[{"1":"ServingStatus","2":[{"1":"UNKNOWN","2":0},{"1":"SERVING","2":1},{"1":"NOT_SERVING","2":2},{"1":"SERVICE_UNKNOWN","2":3}]}]}';
    var dp = DescriptorProto.fromJson(dpJson);
    var dm = DynamicMessage.fromDescriptor(dp, 'grpc.health.v1');
    dm.mergeFromProto3Json(jsonDecode('{"status":"SERVING"}'));
    //dm.set('status', 'SERVING');
    expect(dm.toProto3Json(), null);
  });
}
