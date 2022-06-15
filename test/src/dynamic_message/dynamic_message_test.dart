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

  test('import from json', () {
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
}
