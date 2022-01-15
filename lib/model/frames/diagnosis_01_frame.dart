import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

class Diagnosis01Frame extends CanFrame {
  static const int CAN_ID = 0x6B2;

  Signal kilometerSignal = Signal(8, 20);
  Signal yearSignal = Signal(28, 7, offset: 2000);
  Signal monthSignal = Signal(35, 4);
  Signal daySignal = Signal(39, 5);
  Signal hourSignal = Signal(44, 5);
  Signal minuteSignal = Signal(49, 6);
  Signal secondSignal = Signal(55, 6);

  Diagnosis01Frame(simpleCanFrame) : super(simpleCanFrame);
  
  int kilometer() => kilometerSignal.asInt(bits);
  DateTime dateTime() => DateTime(
    yearSignal.asInt(bits),
    monthSignal.asInt(bits),
    daySignal.asInt(bits),
    hourSignal.asInt(bits),
    minuteSignal.asInt(bits),
    secondSignal.asInt(bits),
  );
}