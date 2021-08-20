import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';

class CanFrame {
  final String rawFrame;

  DateTime date = DateTime.now();
  Uint8List bytes = Uint8List(8);
  Uint16List bytes16 = Uint16List(4);
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

    for (int i = 0; i < 4; i++) {
      bytes16[i] = (bytes[i] << 8) + bytes[i + 1];
    }
  }

  @override
  String toString() {
    return date.toString() + ' ' + rawFrame + ' ' + bytes.toString() + ' ' + bytesToAsciiString();
  }

  String bytesToAsciiString() {
    return bytes.where((e) => e >= 32 && e <= 127).map((e) => String.fromCharCode(e)).join('');
  }
  
  List<String> bytesToString() {
    return bytes.map((byte) => byte.toRadixString(16).toUpperCase().padLeft(2, '0') + ' (' + byte.toString() + ')\n' + byte.toRadixString(2).padLeft(8, '0')).toList();
  }

  List<String> bytes16ToString() {
    return bytes16.map((byte) => byte.toRadixString(16).toUpperCase().padLeft(4, '0') + ' (' + byte.toString() + ')').toList();
  }

  List<int> compareBytes(Uint8List bytes) {
    return this.bytes.asMap().entries.map((e) => e.value - bytes[e.key]).toList();
  }
}