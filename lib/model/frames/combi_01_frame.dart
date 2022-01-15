import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Combi01Frame extends CanFrame {
  static const int CAN_ID = 0x30B;

  BooleanSignal absLampSignal = BooleanSignal(0);
  BooleanSignal espLampSignal = BooleanSignal(1);
  BooleanSignal bklLampSignal = BooleanSignal(2); // BKL ?
  BooleanSignal airbagLampSignal = BooleanSignal(3);
  BooleanSignal silaValidSignal = BooleanSignal(4); // SILA ?
  BooleanSignal steeringLampSignal = BooleanSignal(5);
  BooleanSignal preglowSystemLampSignal = BooleanSignal(6); // Diesel
  BooleanSignal nvInDisplaySignal = BooleanSignal(7); // NV ?
  BooleanSignal displayStatusAccSignal = BooleanSignal(12);
  Signal displayStatusGraSignal = Signal(13, 2); // GRA = Speed pilot ?
  BooleanSignal pressureSwitchSignal = BooleanSignal(15);
  BooleanSignal tankWarningSignal = BooleanSignal(16);
  BooleanSignal mfaSignal = BooleanSignal(17); // MFA = Multi Function Actuator : logs and stores data for distance, ave. speed, ave.fuel mileage, etc per trip and automattically resets after the car has been off for a certain amount of time
  BooleanSignal actuatorTestSignal = BooleanSignal(18);
  Signal indicatorErrorLdwSignal = Signal(19, 2); // LDW = Lane Departure Warning
  BooleanSignal variantUsaSignal = BooleanSignal(21);
  BooleanSignal fieldPressureWarningSignal = BooleanSignal(22);
  BooleanSignal handbrakeSignal = BooleanSignal(23);
  Signal speedDigital = Signal(24, 9);
  BooleanSignal plaInDisplaySignal = BooleanSignal(33); // PLA ?
  BooleanSignal displayErrorNvSignal = BooleanSignal(34); // NV ?
  Signal displayStatusLimiterSignal = Signal(35, 2);
  Signal speedSignal = Signal(48, 10);
  BooleanSignal tachoSignal = BooleanSignal(58);
  BooleanSignal consistencyAccSignal = BooleanSignal(59);
  BooleanSignal displayErrorAccSignal = BooleanSignal(60);
  Signal displayErrorSwaSignal = Signal(61, 2); // SWA = Steering Wheel Angle ?

  Combi01Frame(simpleCanFrame) : super(simpleCanFrame);

  bool isHandbrakeEngaged() => handbrakeSignal.asBoolean(bits);
  int speed() => speedDigital.asInt(bits);
  bool isTankEmptySoon() => tankWarningSignal.asBoolean(bits);
}