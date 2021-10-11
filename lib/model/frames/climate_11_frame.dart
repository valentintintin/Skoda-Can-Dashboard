import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Climate11Frame extends CanFrame {
  static const int CAN_ID = 0x3B5;

  BooleanSignal acSwitchSignal = BooleanSignal(2);

  Climate11Frame(rawFrameOrData) : super(rawFrameOrData, canId: CAN_ID);
  
  bool isAcActivated() => acSwitchSignal.asBoolean(bits);
}