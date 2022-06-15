import 'package:devhelper_grpc/proto/descriptor.pb.dart';
import 'package:devhelper_grpc/proto/reflection.pbgrpc.dart';
import 'package:grpc/grpc.dart';

class ReflectionClient {
  ServerReflectionClient client;

  ReflectionClient(ClientChannel c) : client = ServerReflectionClient(c);

  Future<List<String>> services() async {
    final req =
        Stream.value(ServerReflectionRequest(host: "", listServices: ""));
    final resStream = client.serverReflectionInfo(req);
    final res = await resStream.single;
    return res.listServicesResponse.service.map((s) => s.name).toList();
  }

  Future<List<MethodDescriptorProto>> methods(String service) async {
    final req = ServerReflectionRequest(
      host: "",
      fileContainingSymbol: service,
    );
    final reqStream = Stream.value(req);
    final resStream = client.serverReflectionInfo(reqStream);
    final res = await resStream.single;
    final fdp = FileDescriptorProto.fromBuffer(
        res.fileDescriptorResponse.fileDescriptorProto[0]);
    final sdp = fdp.service
        .firstWhere((sdp) => fdp.package + "." + sdp.name == service);
    return sdp.method;
  }

  Future<DescriptorProto> message(String name) async {
    final req = ServerReflectionRequest(
      host: "",
      fileContainingSymbol: name,
    );
    final reqStream = Stream.value(req);
    final resStream = client.serverReflectionInfo(reqStream);
    final res = await resStream.single;
    final fdp = FileDescriptorProto.fromBuffer(
        res.fileDescriptorResponse.fileDescriptorProto[0]);
    return fdp.messageType
        .firstWhere((dp) => fdp.package + "." + dp.name == name);
  }

  Future<FileDescriptorProto> fdp(String symbol) async {
    final req = ServerReflectionRequest(
      host: "",
      fileContainingSymbol: symbol,
    );
    final reqStream = Stream.value(req);
    final resStream = client.serverReflectionInfo(reqStream);
    final res = await resStream.single;
    return FileDescriptorProto.fromBuffer(
        res.fileDescriptorResponse.fileDescriptorProto[0]);
  }
}
