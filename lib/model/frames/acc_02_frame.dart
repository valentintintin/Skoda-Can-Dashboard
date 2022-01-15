import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class Acc02Frame extends CanFrame {
  static const int CAN_ID = 0x30C;
  static const int MAX_SPEED = 200;
  static const int MAX_DISTANCE = 15;

  Signal desiredSpeedSignal = Signal(12, 10, factor: 0.32);
  StatesSignal statusPrimAnzSignal = StatesSignal(22, 2, [
    SignalState(value: 0, state: 'Disabled'),
    SignalState(value: 1, state: 'Enabled'),
  ]); // Boolean
  Signal distanceSignal = Signal(24, 10);
  BooleanSignal displayTimeLapsSignal = BooleanSignal(42);
  StatesSignal displayPrioSignal = StatesSignal(44, 2, [
    SignalState(value: 4, state: "Near !"),
  ]); // Boolean
  Signal relevantObjectSignal = Signal(46, 2);
  StatesSignal statusDisplaySignal = StatesSignal(61, 3, [
  ]);
  
  Acc02Frame(simpleCanFrame) : super(simpleCanFrame);
  
  bool isSpeedEnabled() => statusPrimAnzSignal.asBoolean(bits);
  int desiredSpeed() {
    int speed = desiredSpeedSignal.asInt(bits);
    return speed <= MAX_SPEED ? speed : 0;
  }
  
  bool isObjectDetected() => relevantObjectSignal.asBoolean(bits);
  int distanceObject() => distanceSignal.asInt(bits);
}