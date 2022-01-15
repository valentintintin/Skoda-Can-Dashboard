import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';
import 'package:skoda_can_dashboard/model/frames/acc_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/blinkmodi_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climate_11_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climatronic_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/engine_04_frame.dart';
import 'package:skoda_can_dashboard/model/frames/esp_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/gateway_72_frame.dart';
import 'package:skoda_can_dashboard/model/frames/motor_14_frame.dart';
import 'package:skoda_can_dashboard/model/frames/pedal_frame.dart';
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/wba_03_frame.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

import 'exceptions/frame_exception.dart';

class CanFrame extends SimpleCanFrame {
  
  factory CanFrame.makeFromSimple(SimpleCanFrame simpleCanFrame) {
    switch (simpleCanFrame.canId) {
      case Combi01Frame.CAN_ID:
        return Combi01Frame(simpleCanFrame);

      case Motor14Frame.CAN_ID:
        return Motor14Frame(simpleCanFrame);

      case Acc02Frame.CAN_ID:
        return Acc02Frame(simpleCanFrame);

      case Blinkmodi02Frame.CAN_ID:
        return Blinkmodi02Frame(simpleCanFrame);

      case Climate11Frame.CAN_ID:
        return Climate11Frame(simpleCanFrame);

      case ClimatronicFrame.CAN_ID:
        return ClimatronicFrame(simpleCanFrame);

      case Diagnosis01Frame.CAN_ID:
        return Diagnosis01Frame(simpleCanFrame);

      case Engine04Frame.CAN_ID:
        return Engine04Frame(simpleCanFrame);

      case Esp02Frame.CAN_ID:
        return Esp02Frame(simpleCanFrame);

      case Gateway72Frame.CAN_ID:
        return Gateway72Frame(simpleCanFrame);

      case StationWagon02Frame.CAN_ID:
        return StationWagon02Frame(simpleCanFrame);

      case Wba03Frame.CAN_ID:
        return Wba03Frame(simpleCanFrame);

      case PedalFrame.CAN_ID:
        return PedalFrame(simpleCanFrame);

      default:
        return CanFrame(simpleCanFrame);
    }
  }

  late Uint16List bytes16;
  late BitArray bits;

  CanFrame(SimpleCanFrame simpleCanFrame) {
    canId = simpleCanFrame.canId;
    bytes = simpleCanFrame.bytes;
    timestamp = simpleCanFrame.timestamp;
    extended = simpleCanFrame.extended;
    bus = simpleCanFrame.bus;
    length = simpleCanFrame.length;
    
    bits = BitArray.fromUint8List(bytes);

    bytes16 = Uint16List(bytes.length ~/ 2);
    for (int i = 0; i < bytes16.length; i++) {
      bytes16[i] = (bytes[i] << 8) + bytes[i + 1];
    }
  }
  
  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + super.toString();
  }

  List<String> bytes16ToString() {
    return bytes16.map((byte) => byte.toRadixString(16).toUpperCase().padLeft(4, '0') + ' (' + byte.toString() + ')').toList();
  }
}


class SimpleCanFrame {
  DateTime dateTimeReceived = DateTime.now();
  Uint8List bytes = Uint8List(8);
  
  int canId = 0;
  int timestamp = 0;
  bool extended = false;
  int bus = 0;
  int length = 0;
  
  SimpleCanFrame();
  
  factory SimpleCanFrame.fromCsv(String rawFrame) {
    SimpleCanFrame canFrame = SimpleCanFrame();
    
    List<String> split = rawFrame.split(',');

    if (split.length < 6) {
      throw new CanFrameCsvWrongException(rawFrame);
    }

    try {
      canFrame.canId = int.parse(split[1].toUpperCase().replaceAll('0X', ''), radix: 16);
    } catch (e) {
      throw new CanFrameCsvNoIdException(rawFrame);
    }

    if (canFrame.canId <= 0) {
      throw new CanFrameCsvNoIdException(rawFrame);
    }

    canFrame.timestamp = int.parse(split[0]);
    canFrame.extended = split[2] == 'true' || split[2] == '1';
    canFrame.bus = int.parse(split[4]);
    canFrame.length = int.parse(split[5]);

    if (canFrame.length > 8) {
      throw new CanFrameCsvTooMuchDataException(rawFrame);
    }

    for (int i = 0; i < 8; i++) {
      if (i < canFrame.length) {
        canFrame.bytes[i] = int.parse(split[6 + i], radix: 16);
      } else {
        canFrame.bytes[i] = 0;
      }
    }
    
    return canFrame;
  }
  
  Uint8List toSavvyCan() {
    Uint8List buffer = Uint8List(12 + bytes.length);

    int ID = canId;
    if (extended) ID |= 1 << 31;

    buffer[0] = 0xF1; //start of a command over serial
    buffer[1] = 0; //command ID for sending a CANBUS frame
    buffer[2] = (timestamp & 0xFF); //four bytes of timestamp LSB first
    buffer[3] = (timestamp >> 8);
    buffer[4] = (timestamp >> 16);
    buffer[5] = (timestamp >> 24);
    buffer[6] = (ID & 0xFF); //four bytes of ID LSB first
    buffer[7] = (ID >> 8);
    buffer[8] = (ID >> 16);
    buffer[9] = (ID >> 24);
    buffer[10] = ((bus) & 0xF0) << 4;
    buffer[10] += length & 0x0F;
    for (int i = 0; i < length; i++)
    {
      buffer[11 + i] = bytes[i];
    }
    buffer[11 + length] = 0;

    return buffer;
  }
  
  void reset() {
    this.timestamp = 0;
    this.length = 0;
    this.bus = 0;
    this.extended = false;
    this.canId = 0;
    this.bytes = Uint8List(8);
    this.dateTimeReceived = DateTime.now();
  }

  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + dateTimeReceived.toString() + ' ' + toCsv() + ' ' + bytesToAsciiString();
  }

  String toCsv() {
    return timestamp.toString() + ',' + canId.toRadixString(16).padLeft(8, '0') + ',' + (extended ? '1' : 'false') + ',' + 'Rx' + ',' + bus.toString() + ',' + length.toString() + ',' + bytes.map((e) => e.toRadixString(16)).join(',');
  }

  String bytesToAsciiString() {
    return bytes.map((e) => byteToAsciiString(e)).join('');
  }

  String byteToAsciiString(int byte) {
    return byte >= 32 && byte <= 127 ? String.fromCharCode(byte) : '';
  }

  List<String> bytesToString() {
    return bytes.map((byte) =>
    byte.toRadixString(16).toUpperCase().padLeft(2, '0')
        + ' (' + byte.toString() + ')'
        + (byteToAsciiString(byte) != '' ? '(' + byteToAsciiString(byte) + ')' : '')
        + '\n' + byte.toRadixString(2).padLeft(8, '0')
    ).toList();
  }

  List<int> compareBytes(Uint8List bytes) {
    return this.bytes.asMap().entries.map((e) => e.value - bytes[e.key]).toList();
  }
  
  CanFrame transformToCanFrame() {
    return CanFrame.makeFromSimple(this);
  }
}