import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class Wba03Frame extends CanFrame {
  static const int CAN_ID = 0x394;

  StatesSignal driveLevelSignal = StatesSignal(12, 4, [
    SignalState(value: 0, state: 'P'),
    SignalState(value: 1, state: 'P'),
    SignalState(value: 2, state: 'R'),
    SignalState(value: 3, state: 'N'),
    SignalState(value: 4, state: 'D'),
  ]);
  Signal gearSignal = Signal(24, 4);
  
  Wba03Frame(simpleCanFrame) : super(simpleCanFrame);
  
  String drivingMode() => 'D';
  String gear() {
    switch(driveLevelSignal.asInt(bits)) {
      case 4:
        return gearSignal.asInt(bits).toString();
      default:
        return driveLevelSignal.asString(bits);
    }
  }
  String gearMode() {
    switch(driveLevelSignal.asInt(bits)) {
      case 4:
        return 'D';
      default:
        return driveLevelSignal.asString(bits);
    }
  }
}