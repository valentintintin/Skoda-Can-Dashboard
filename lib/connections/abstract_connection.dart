import 'dart:async';

import 'package:skoda_can_dashboard/model/can_frame.dart';

abstract class Connection {
  final StreamController<CanFrame> streamControllerCanFrame;
  
  Connection(this.streamControllerCanFrame) {}

  bool isConnected();

  void addNewFrame(CanFrame canFrame) {
    streamControllerCanFrame.add(canFrame);
  }
} 