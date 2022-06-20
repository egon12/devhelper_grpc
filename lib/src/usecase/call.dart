import 'package:devhelper_grpc/src/dynamic_message/dynamic_message.dart';
import 'package:devhelper_grpc/src/reflection/reflection.dart';

class Call {
  String methodName;
  DynamicMessage req;
  DynamicMessage res;

  Call({required this.methodName, required this.req, required this.res});
}

class CallBlock {
  String path;
  List<String> header;
  Map<String, dynamic> body;
  String raw;
  int start;
  int end;

  CallBlock(
    this.path, {
    required this.start,
    required this.end,
    this.raw = '',
    this.header = const [],
    this.body = const <String, dynamic>{},
  });

  Future<CallExecutor> generate(ReflectionClient rc) async {
    final services = await rc.services();
    final service = services.firstWhere((service) => service == path.package());

    final methods = await rc.methods(service);
    final method = methods.firstWhere((method) => method.name == path.method());

    final inputDP = await rc.message(method.inputType.substring(1));
    final outputDP = await rc.message(method.outputType.substring(1));

    final reqDM = DynamicMessage.fromDescriptor(
        inputDP, method.inputType.substring(1).package());
    final resDM = DynamicMessage.fromDescriptor(
        outputDP, method.outputType.substring(1).package());

    return CallExecutor(path: path, req: reqDM, res: resDM);
  }
}

class CallExecutor {
  String path;
  DynamicMessage req;
  DynamicMessage res;

  CallExecutor({required this.path, required this.req, required this.res});
}

typedef CallBlocks = List<CallBlock>;

extension SearchCallBlock on CallBlocks {
  CallBlock? at(int pos) {
    for (CallBlock cb in this) {
      if (cb.start <= pos && pos < cb.end) {
        return cb;
      }
    }
    return null;
  }
}

extension GRPCIdentity on String {
  String package() {
    final arr = split('/');
    return arr[arr.length - 2];
  }

  String method() => split('/').last;
}
