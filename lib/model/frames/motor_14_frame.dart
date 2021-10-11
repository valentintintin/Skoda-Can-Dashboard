import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class Motor14Frame extends CanFrame {
  static const int CAN_ID = 0x3BE;

  StatesSignal startStopStatusSignal = StatesSignal(12, 2, [
    SignalState(value: 3, state: 'Enabled'),
  ]);
  BooleanSignal startStopRestartSignal = BooleanSignal(14);
  BooleanSignal startStopStopSignal = BooleanSignal(15);
  StatesSignal startStopDriversRequestSignal = StatesSignal(24, 2, [
  ]);
  BooleanSignal driverBrakingSignal = BooleanSignal(28);
  BooleanSignal engineRunningSignal = BooleanSignal(39);
  
  Motor14Frame(rawFrameOrData) : super(rawFrameOrData, canId: CAN_ID);
  
  bool isBraking() => driverBrakingSignal.asBoolean(bits);
  bool isEngineRunning() => engineRunningSignal.asBoolean(bits);
}