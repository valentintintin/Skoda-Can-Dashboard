import 'dart:async';

import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:web_socket_channel/io.dart';

class ClientWebsocket {

  final StreamController<VehicleState> streamController;
  IOWebSocketChannel? channel;

  ClientWebsocket(this.streamController) {
  }
  
  void init(String ipServer, int port, String subject) {
    channel = IOWebSocketChannel.connect("ws://${ipServer}:${port}/${subject}");
    
    channel!.stream.listen((message) {
      try {
        String json = String.fromCharCodes(message);
        print(json);
        streamController.sink.add(VehicleState.fromJson(json));
      } catch (e, stacktrace) {
        print("Erreur " + e.toString() + " " + stacktrace.toString());
        // ignored
      }
    }).onError((e) {
      print('Websocket error : ' + e.toString());
      return channel = null;
    });
  }

  bool isConnected() {
    return channel != null && channel!.closeCode == null;
  }
}