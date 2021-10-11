import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Esp02Frame extends CanFrame {
  static const int CAN_ID = 0x101;

  Signal yawRateSignal = Signal(40, 14, factor: 0.01);
  BooleanSignal vzYawRateSignal = BooleanSignal(54);
  BooleanSignal emergencyBrakeIndicatorSignal = BooleanSignal(55);
  UInt8Signal transverseAccelerationSignal = UInt8Signal(16, factor: 0.01, offset: -1.27);

  Esp02Frame(rawFrameOrData) : super(rawFrameOrData, canId: CAN_ID);
  
  double yawRate() => yawRateSignal.asDouble(bits);
  bool isVzYawRate() => vzYawRateSignal.asBoolean(bits);
  bool isEmergencyBrakeIndicatorActivated() => emergencyBrakeIndicatorSignal.asBoolean(bits);
  double transverseAcceleration() => transverseAccelerationSignal.asDouble(bits);
}