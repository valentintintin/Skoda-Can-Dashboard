import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class ClimatronicFrame extends CanFrame {
  static const int CAN_ID = 0x668;
  
  StatesSignal speedSignal = StatesSignal(24, 8, [
    SignalState(value: 0, state: '0'),
    SignalState(value: 37, state: '1'),
    SignalState(value: 67, state: '2'),
    SignalState(value: 87, state: '3'),
    SignalState(value: 107, state: '4'),
    SignalState(value: 137, state: '5'),
    SignalState(value: 173, state: '6'),
    SignalState(value: 219, state: '7'),
  ]);
  
  ClimatronicFrame(simpleCanFrame) : super(simpleCanFrame);
  
  int speed() => speedSignal.asState(bits).asInt();
}