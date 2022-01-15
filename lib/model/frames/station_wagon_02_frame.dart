import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class StationWagon02Frame extends CanFrame {
  static const int CAN_ID = 0x6B7;

  Signal kilometerSignal = Signal(0, 20);
  UInt8Signal outsideTempSignal = UInt8Signal(56, offset: -50, factor: 0.5);
  Signal contentTankSignal = Signal(40, 7);
  BooleanSignal kbiFStatusTankSignal = BooleanSignal(47);

  StationWagon02Frame(simpleCanFrame) : super(simpleCanFrame);

  int kilometer() => kilometerSignal.asInt(bits);
  double temperatureOutside() => outsideTempSignal.asDouble(bits); 
  int contentTank() => contentTankSignal.asInt(bits); 
}