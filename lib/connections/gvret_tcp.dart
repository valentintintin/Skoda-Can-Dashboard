import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:skoda_can_dashboard/connections/abstract_gvret.dart';

class GvretTcp extends Gvret {
  Socket? socket;

  GvretTcp(streamControllerFrame) : super(streamControllerFrame);

  Future<void> init(String ip, int port, { int timeout = 4 }) async {
    if (socket != null) {
      socket!.close();
      socket = null;
    }

    print('Try socket');

    // fixme throw exception, how to catch ?
    socket = await Socket.connect(ip, port, timeout: Duration(seconds: timeout));

    print('Socket connected');

    onConnectionSucceded();

    socket!.listen((data) {
      data.forEach((c) {
        onReceiveValue(c);
      });
    }, onError: (e) {
      print('Socket diconnected : ' + e.toString());
      socket = null;
    });
  }

  @override
  void writeValues(Uint8List data) {
    socket!.add(data);
  }

  @override
  bool isConnected() {
    return socket != null;
  }
}