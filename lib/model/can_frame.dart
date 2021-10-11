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
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/wba_03_frame.dart';

import 'exceptions/frame_exception.dart';

class CanFrame {
  static int _decodeCanIdFromRawFrame(rawFrameOrData) {
    int canId = 0;

    if (rawFrameOrData is String) {
      List<String> split = rawFrameOrData.split(',');

      if (split.length < 6) {
        throw new CanFrameCsvWrongException(rawFrameOrData);
      }

      try {
        canId = int.parse(split[1].toUpperCase().replaceAll('0X', ''), radix: 16);
      } catch (e) {
        throw new CanFrameNoIdException(rawFrameOrData);
      }

      if (canId <= 0) {
        throw new CanFrameNoIdException(rawFrameOrData);
      }
    } else if (rawFrameOrData is Uint8List) {
      canId = rawFrameOrData[6] + (rawFrameOrData[7] << 8) + (rawFrameOrData[8] << 16) + (rawFrameOrData[9] << 24);
    }

    return canId;
  }

  factory CanFrame.make(rawFrameOrData, { int canId = 0 }) {
    if (canId == 0) {
      canId = _decodeCanIdFromRawFrame(rawFrameOrData);
    }
    
    switch (canId) {
      case Combi01Frame.CAN_ID:
        return Combi01Frame(rawFrameOrData);

      case Motor14Frame.CAN_ID:
        return Motor14Frame(rawFrameOrData);

      case Acc02Frame.CAN_ID:
        return Acc02Frame(rawFrameOrData);

      case Blinkmodi02Frame.CAN_ID:
        return Blinkmodi02Frame(rawFrameOrData);

      case Climate11Frame.CAN_ID:
        return Climate11Frame(rawFrameOrData);

      case ClimatronicFrame.CAN_ID:
        return ClimatronicFrame(rawFrameOrData);

      case Diagnosis01Frame.CAN_ID:
        return Diagnosis01Frame(rawFrameOrData);

      case Engine04Frame.CAN_ID:
        return Engine04Frame(rawFrameOrData);

      case Esp02Frame.CAN_ID:
        return Esp02Frame(rawFrameOrData);

      case Gateway72Frame.CAN_ID:
        return Gateway72Frame(rawFrameOrData);

      case StationWagon02Frame.CAN_ID:
        return StationWagon02Frame(rawFrameOrData);

      case Wba03Frame.CAN_ID:
        return Wba03Frame(rawFrameOrData);

      default:
        return CanFrame(rawFrameOrData, canId: canId);
    }
  }

  DateTime dateTimeReceived = DateTime.now();
  Uint8List bytes = Uint8List(8);
  late Uint16List bytes16;
  late BitArray bits;

  int canId = 0;
  int timestamp = 0;
  bool extended = false;
  int bus = 0;
  int length = 0;

  CanFrame(rawFrameOrData, { this.canId = 0 }) {
    dateTimeReceived = DateTime.now();

    if (canId == 0) {
      canId = _decodeCanIdFromRawFrame(rawFrameOrData);
    }
    
    if (rawFrameOrData is String) {
      _fromCsvFrame(rawFrameOrData, canId: canId);
    } else if (rawFrameOrData is Uint8List) {
      _fromSavvyCan(rawFrameOrData, canId: canId);
    }

    bits = BitArray.fromUint8List(bytes);

    bytes16 = Uint16List(bytes.length ~/ 2);
    for (int i = 0; i < bytes16.length; i++) {
      bytes16[i] = (bytes[i] << 8) + bytes[i + 1];
    }
  }

  void _fromCsvFrame(String rawFrame, { int canId = 0 }) {
    List<String> split = rawFrame.split(',');

    timestamp = int.parse(split[0]);
    extended = split[2] == 'true';
    bus = int.parse(split[4]);

    length = int.parse(split[5]);

    if (length > 8) {
      throw new CanFrameTooMuchDataException(rawFrame);
    }

    for (int i = 0; i < 8; i++) {
      if (i < length) {
        bytes[i] = int.parse(split[6 + i], radix: 16);
      } else {
        bytes[i] = 0;
      }
    }
  }

  void _fromSavvyCan(Uint8List data, { int canId = 0 }) {
    //print(data.map((e) => e.toRadixString(16)).join(' '));

    if (data[0] != 0xF1 || data[1] != 0 || data.length < 11) {
      throw new FrameWrongLengthException();
    }

/*
      Binary:
      Byte 0 - 0xF1
      Byte 1 - 00
      Byte 2-5 - Time stamp in microseconds LSB to MSB
      Byte 6-9 - Frame ID, Bit 31 - Extended Frame
      Byte 10 - Frame length in bottom 4 bits, Bus received on in upper 4 bits
      Byte 11-? - Data bytes
      Byte ?+1 - 0
       */

    if (canId == 0) {
      canId = _decodeCanIdFromRawFrame(data);
    }
    timestamp = data[2] + (data[3] << 8) + (data[4] << 16) + (data[5] << 24);
    extended = false;
    if ((canId & 1 << 31) == 1 << 31)
    {
      canId &= 0x7FFFFFFF;
      extended = true;
    }
    bus = (data[10] & 0xF0) >> 4;
    length = data[10] & 0x0F;
    if (data.length - 11 < length) {
      throw new FrameDataMissingForLengthException();
    }
    
    if (data[11 + length] != 0) {
      throw new FrameWrongException();
    }
    
    bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = data[11 + i];
    }
  }

  Uint8List toSavvyCan() {
    Uint8List buffer = Uint8List(12 + length);

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

  @override
  String toString() {
    return this.runtimeType.toString() + ' ' + dateTimeReceived.toString() + ' ' + toCsv() + ' ' + bytesToAsciiString();
  }

  String toCsv() {
    return timestamp.toString() + ',' + canId.toRadixString(16).padLeft(8, '0') + ',' + (extended ? 'true' : 'false') + ',' + 'Rx' + ',' + bus.toString() + ',' + length.toString() + ',' + bytes.map((e) => e.toRadixString(16)).join(',');
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