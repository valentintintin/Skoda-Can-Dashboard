import 'dart:io';
import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

Future<void> main() async {
  Uint8List list = Uint8List(8);
  list[0] = 0xBE;
  list[1] = 0xB5;
  list[2] = 0xDE;
  list[3] = 0x50;
  list[4] = 0x41;
  list[5] = 0x16;
  list[6] = 0x55;
  list[7] = 0x22;
  BitArray bits = BitArray.fromUint8List(list);
  
  Signal signal = Signal(8, 20);
  print(signal.asDoubleRaw(bits));

  signal = Signal(35, 4);
  print(signal.asDoubleRaw(bits));
  exit(0);
}