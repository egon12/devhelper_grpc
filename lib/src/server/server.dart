import 'package:devhelper_grpc/src/reflection/reflection.dart';
import 'package:grpc/grpc.dart';

class Server {

  String host;

  int port;

  bool useTLS;

  Server(this.host, this.port, [this.useTLS = false]);

  ClientChannel? _channel;

  ClientChannel get channel {
    var _chan = _channel;
    if (_chan != null) {
      return _chan;
    }

    var credentials = const ChannelCredentials.secure();
    if (!useTLS) {
      credentials = const ChannelCredentials.insecure();
    }

    var options = ChannelOptions(credentials: credentials);

    _chan = ClientChannel(host, port: port, options: options);

    _channel = _chan;

    return _chan;
  }

  ReflectionClient get reflection {
    return ReflectionClient(channel);
  }
}
