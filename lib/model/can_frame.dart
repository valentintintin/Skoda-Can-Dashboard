import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';

class CanFrame {
  final String rawFrame;
  Uint8List bytes = Uint8List(8);
  BitArray bits = BitArray(8 * 8);

  String canId = '';
  int timestamp = 0;

  CanFrame(this.rawFrame) {
    List<String> split = rawFrame.split(',');

    if (split.length < 12) {
      throw new Exception('Not enough data in frame');
    }

    canId = split[1].toUpperCase().replaceAll('0X', '').padLeft(8, '0');

    if (canId.isEmpty) {
      throw new Exception('Can id empty');
    }

    timestamp = int.parse(split[0]);

    bytes = Uint8List.fromList([
      int.parse(split[6],radix: 16),
      int.parse(split[7],radix: 16),
      int.parse(split[8],radix: 16),
      int.parse(split[9],radix: 16),
      int.parse(split[10],radix: 16),
      int.parse(split[11],radix: 16),
      int.parse(split[12],radix: 16),
      int.parse(split[13],radix: 16),
    ]);

    bits = BitArray.fromUint8List(bytes);
  }

  @override
  String toString() {
    return rawFrame + ' ' + bytes.toString() + ' ' + bytesToAsciiString();
  }

  String bytesToAsciiString() {
    return bytes.where((e) => e >= 32 && e <= 127).map((e) => String.fromCharCode(e)).join('');
  }
}