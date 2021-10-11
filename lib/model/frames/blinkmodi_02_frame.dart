import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class Blinkmodi02Frame extends CanFrame {
  static const int CAN_ID = 0x366;
  
  BooleanSignal hazardSwitchSignal = BooleanSignal(20);
  BooleanSignal comfortSignalLeftSignal = BooleanSignal(23);
  BooleanSignal comfortSignalRightSignal = BooleanSignal(24);
  BooleanSignal leftTurnExteriorBulb1Signal = BooleanSignal(25);
  BooleanSignal rightTurnExteriorBulb1Signal = BooleanSignal(26);
  BooleanSignal leftTurnExteriorBulb2Signal = BooleanSignal(27);
  BooleanSignal rightTurnExteriorBulb2Signal = BooleanSignal(28);
  StatesSignal fastSendRateSignal = StatesSignal(37, 1, [
    SignalState(value: 0, state: '1 Hz'),
    SignalState(value: 1, state: '50 Hz'),
  ]);
  
  Blinkmodi02Frame(rawFrameOrData) : super(rawFrameOrData, canId: CAN_ID);
  
  bool isLeftTurnIndicatorActivated() => leftTurnExteriorBulb1Signal.asBoolean(bits) || leftTurnExteriorBulb2Signal.asBoolean(bits); 
  bool isRightTurnIndicatorActivated() => rightTurnExteriorBulb1Signal.asBoolean(bits) || rightTurnExteriorBulb2Signal.asBoolean(bits);
  bool isTurnIndicatorActivated(TurnIndicatorDirection direction) => direction == TurnIndicatorDirection.left ? isLeftTurnIndicatorActivated() : isRightTurnIndicatorActivated();
}

enum TurnIndicatorDirection {
  left,
  right
}