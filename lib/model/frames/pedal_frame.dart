import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class PedalFrame extends CanFrame {
  static const int CAN_ID = 0x3EA;

  Signal brakePedalSignal = Signal(24, 8, offset: -16);
  Signal throttlePedalSignal = Signal(40, 8, offset: -125);

  PedalFrame(simpleCanFrame) : super(simpleCanFrame);
  
  int brakePedalIntensity() => brakePedalSignal.asInt(bits);
  
  int throttlePedalIntensity() => throttlePedalSignal.asInt(bits);
}