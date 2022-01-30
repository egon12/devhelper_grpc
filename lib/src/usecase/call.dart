import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'package:devhelper_grpc/src/dynamic_message.dart';

class Call {
  String methodName;
  DynamicMessage req;
  DynamicMessage res;

  Call({required this.methodName, required this.req, required this.res});
}
