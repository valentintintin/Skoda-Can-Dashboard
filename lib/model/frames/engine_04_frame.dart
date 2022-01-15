import 'dart:typed_data';

import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Engine04Frame extends CanFrame {
  static const int CAN_ID = 0x107;

  Signal engineSpeedSignal = Signal(24, 12, factor: 3);
  Signal chargePressureSignal = Signal(39, 9, factor: 0.01);
  
  Engine04Frame(simpleCanFrame) : super(simpleCanFrame);
  
  int engineSpeed() => engineSpeedSignal.asInt(bits);
  double chargePressure() => chargePressureSignal.asDouble(bits);
}