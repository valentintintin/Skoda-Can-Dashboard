import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Gateway72Frame extends CanFrame {
  static const int CAN_ID = 0x3DB;

  UInt8Signal outsideTempSignal = UInt8Signal(56, offset: -50, factor: 0.5);

  Gateway72Frame(simpleCanFrame) : super(simpleCanFrame);
  
  double temperatureOutside() => outsideTempSignal.asDouble(bits); 
}