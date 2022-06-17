import 'package:uuid/uuid.dart';
import '../../proto/descriptor.pb.dart';

var uuidgen = const Uuid();

class CallPersistent {
  String id;
  String name;
  int groupID;

  String host;
  int port;

  String pkg;
  String service;
  String method;

  DescriptorProto reqProto;
  DescriptorProto resProto;

  String req;
  String? res;

  CallPersistent({
    this.id = '',
    required this.name,
    this.groupID = 0,
    required this.host,
    required this.port,
    required this.pkg,
    required this.service,
    required this.method,
    required this.reqProto,
    required this.resProto,
    this.req = '{}',
    this.res,
  }) {
    if (id.isEmpty) {
      id = uuidgen.v4();
    }
  }

  factory CallPersistent.fromMap(Map<String, dynamic> m) {
    var id = m['id'] as String;
    var name = m['name'] as String;
    var host = m['host'] as String;
    var port = m['port'] as int;
    var pkg = m['pkg'] as String;
    var service = m['service'] as String;
    var method = m['method'] as String;
    var reqProto = DescriptorProto.fromBuffer(m['reqProto'] as List<int>);
    var resProto = DescriptorProto.fromBuffer(m['resProto'] as List<int>);
    var req = m['req'] as String;
    var res = m['res'] as String?;

    return CallPersistent(
      id: id,
      name: name,
      host: host,
      port: port,
      pkg: pkg,
      service: service,
      method: method,
      reqProto: reqProto,
      resProto: resProto,
      req: req,
      res: res,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'port': port,
      'pkg': pkg,
      'service': service,
      'method': method,
      'reqProto': reqProto.writeToBuffer(),
      'resProto': resProto.writeToBuffer(),
      'req': req,
      'res': res,
    };
  }

  CallViewObject toViewObject() {
    return CallViewObject(
        pkg: pkg, service: service, method: method, request: req);
  }
}

class CallViewObject {
  String pkg;
  String service;
  String method;

  String request;

  CallViewObject(
      {required this.pkg,
      required this.service,
      required this.method,
      required this.request});
}
