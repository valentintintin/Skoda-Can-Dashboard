// To parse this JSON data, do
//
//     final dbc = dbcFromJson(jsonString);

import 'dart:convert';

import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';

class Dbc {
  Dbc({
    required this.canId,
    required this.pgn,
    required this.name,
    required this.label,
    required this.isExtendedFrame,
    required this.dlc,
    required this.comment,
    required this.signals,
  });

  final String canId;
  final int pgn;
  final String name;
  final String label;
  final bool isExtendedFrame;
  final int dlc;
  final String? comment;
  final List<Signal> signals;

  factory Dbc.fromRawJson(String str) => Dbc.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Dbc.fromJson(Map<String, dynamic> json) => Dbc(
    canId: (json["canId"].toRadixString(16) as String).padLeft(8, '0').toUpperCase(),
    pgn: json["pgn"],
    name: json["name"],
    label: json["label"],
    isExtendedFrame: json["isExtendedFrame"],
    dlc: json["dlc"],
    comment: json["comment"],
    signals: List<Signal>.from(json["signals"].map((x) => Signal.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "canId": canId,
    "pgn": pgn,
    "name": name,
    "label": label,
    "isExtendedFrame": isExtendedFrame,
    "dlc": dlc,
    "comment": comment,
    "signals": List<dynamic>.from(signals.map((x) => x.toJson())),
  };
}

class Signal {
  Signal({
    required this.name,
    required this.label,
    required this.startBit,
    required this.bitLength,
    required this.isLittleEndian,
    required this.isSigned,
    required this.factor,
    required this.offset,
    required this.min,
    required this.max,
    required this.dataType,
    required this.choking,
    required this.visibility,
    required this.interval,
    required this.category,
    required this.comment,
    required this.lineInDbc,
    required this.problems,
    required this.sourceUnit,
    required this.postfixMetric,
    required this.states,
  });

  final String name;
  final String label;
  final int startBit;
  final int bitLength;
  final bool isLittleEndian;
  final bool isSigned;
  final double factor;
  final double offset;
  final double min;
  final double max;
  final String dataType;
  final bool choking;
  final bool visibility;
  final int interval;
  final String category;
  final String? comment;
  final int lineInDbc;
  final List<String> problems;
  final String? sourceUnit;
  final String? postfixMetric;
  final List<DbcState>? states;

  factory Signal.fromRawJson(String str) => Signal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Signal.fromJson(Map<String, dynamic> json) => Signal(
    name: json["name"],
    label: json["label"],
    startBit: json["startBit"],
    bitLength: json["bitLength"],
    isLittleEndian: json["isLittleEndian"],
    isSigned: json["isSigned"],
    factor: json["factor"].toDouble(),
    offset: json["offset"].toDouble(),
    min: json["min"].toDouble(),
    max: json["max"].toDouble(),
    dataType: json["dataType"],
    choking: json["choking"],
    visibility: json["visibility"],
    interval: json["interval"],
    category: json["category"],
    comment: json["comment"] == null ? null : json["comment"],
    lineInDbc: json["lineInDbc"],
    problems: List<String>.from(json["problems"].map((x) => x)),
    sourceUnit: json["sourceUnit"] == null ? null : json["sourceUnit"],
    postfixMetric: json["postfixMetric"] == null ? null : json["postfixMetric"],
    states: json["states"] == null ? null : List<DbcState>.from(json["states"].map((x) => DbcState.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "label": label,
    "startBit": startBit,
    "bitLength": bitLength,
    "isLittleEndian": isLittleEndian,
    "isSigned": isSigned,
    "factor": factor,
    "offset": offset,
    "min": min,
    "max": max,
    "dataType": dataType,
    "choking": choking,
    "visibility": visibility,
    "interval": interval,
    "category": category,
    "comment": comment == null ? null : comment,
    "lineInDbc": lineInDbc,
    "problems": List<dynamic>.from(problems.map((x) => x)),
    "sourceUnit": sourceUnit == null ? null : sourceUnit,
    "postfixMetric": postfixMetric == null ? null : postfixMetric,
    "states": states == null ? null : List<dynamic>.from(states!.map((x) => x.toJson())),
  };

  bool getValueFromBitesAsBoolean(BitArray bits) => getValueFromBites(bits) == 1;

  String getValueFromBitesAsString(BitArray bits) {
    double value = getValueFromBites(bits);

    try {
      return states!.firstWhere((element) => element.value == value).state;
    } catch (e) {
      return value.toString();
    }
  }

  String getValueFromBitesAsAscii(BitArray bits) {
    return String.fromCharCode(getValueFromBites(bits).toInt());
  }

  double getValueFromBites(BitArray bits) {
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

    return (value * (factor != 0 ? factor : 1)) + (offset != 0 ? offset : 0);
  }
}

class DbcState {
  DbcState({
    required this.value,
    required this.state,
  });

  final double value;
  final String state;

  factory DbcState.fromRawJson(String str) => DbcState.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DbcState.fromJson(Map<String, dynamic> json) => DbcState(
    value: json["value"].toDouble(),
    state: json["state"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "state": state,
  };
}
