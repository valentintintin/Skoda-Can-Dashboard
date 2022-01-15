import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';
import 'package:skoda_can_dashboard/model/signal_state.dart';

class Signal {
  final int startBit;
  final int bitLength;
  late bool isLittleEndian;
  bool isSigned;
  late double? factor;
  final double? offset;

  Signal(this.startBit, this.bitLength, {
    this.isSigned = false,
    this.isLittleEndian = true,
    this.factor = 1,
    this.offset,
  });

  bool asBoolean(BitArray bits) => asDouble(bits) >= 1;

  String asAscii(BitArray bits) {
    return String.fromCharCode(asDouble(bits).toInt());
  }
  
  int asInt(BitArray bits) {
    return asDouble(bits).round();
  }

  double asDouble(BitArray bits) {
    double value = asDoubleRaw(bits);
    
    return (value * ((factor != 0 ? factor : 1) ?? 1)) + ((offset != 0 ? offset : 0) ?? 0);
  }

  double asDoubleRaw(BitArray bits) {
    var endian = isLittleEndian ? Endian.little : Endian.big;
    int endBit = startBit + bitLength;

    BitArray subBits = BitArray(bitLength);

    int j = 0;
    for (var i = 0; i < bits.length; i++) {
      if (i >= startBit && i < endBit) {
        subBits[j++] = bits[i];
      }
    }

    var sublist = subBits.byteBuffer.asByteData();

    double value = 0;

    if (bitLength <= 8) {
      if (isSigned) {
        value = sublist.getInt8(0).toDouble();
      } else {
        value = sublist.getUint8(0).toDouble();
      }
    } else if (bitLength <= 8 * 2) {
      if (isSigned) {
        value = sublist.getInt16(0, endian).toDouble();
      } else {
        value = sublist.getUint16(0, endian).toDouble();
      }
    } else if (bitLength <= 8 * 3) {
      if (isSigned) {
        value = sublist.getInt32(0, endian).toDouble();
      } else {
        value = sublist.getUint32(0, endian).toDouble();
      }
    } else if (bitLength <= 8 * 4) {
      if (isSigned) {
        value = sublist.getInt64(0, endian).toDouble();
      } else {
        value = sublist.getUint64(0, endian).toDouble();
      }
    }

    return value;
  }
}

class BooleanSignal extends Signal {
  BooleanSignal(int startBit) : super(startBit, 1);
  
  bool isTrue(BitArray bits) => asBoolean(bits);
  bool isFalse(BitArray bits) => !asBoolean(bits);
}

class Int8Signal extends Signal {
  Int8Signal(int startBit, { double? factor, double? offset }) : super(startBit, 8,
      factor: factor,
      offset: offset,
      isLittleEndian: false,
      isSigned: true);
}

class UInt8Signal extends Signal {
  UInt8Signal(int startBit, { double? factor, double? offset }) : super(startBit, 8,
      factor: factor,
      offset: offset,
      isLittleEndian: false,
      isSigned: false);
}

class Int16Signal extends Signal {
  Int16Signal(int startBit, { double? factor, double? offset }) : super(startBit, 16,
      factor: factor,
      offset: offset,
      isLittleEndian: false,
      isSigned: true);
}

class UInt16Signal extends Signal {
  UInt16Signal(int startBit, { double? factor, double? offset }) : super(startBit, 16,
      factor: factor,
      offset: offset,
      isLittleEndian: false,
      isSigned: false);
}

class StatesSignal extends Signal {
  final List<SignalState> states;

  StatesSignal(int startBit, int bitLength, this.states, { bool isLittleEndian = true }) : super(startBit, bitLength,
      isLittleEndian: isLittleEndian,
      isSigned: false);
  
  SignalState asState(BitArray bits) {
    double value = asDouble(bits);

    try {
      return states.firstWhere((element) => element.value == value);
    } catch (e) {
      return SignalState(value: value, state: value.toString());
    }
  }
  
  String asString(BitArray bits) {
    return asState(bits).state;
  }
}