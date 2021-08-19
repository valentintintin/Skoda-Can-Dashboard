import 'dart:convert';
import 'dart:typed_data';

import 'package:bit_array/bit_array.dart';

import 'dbc_signal_state.dart';

class DbcSignal {
  DbcSignal({
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
  final List<DbcSignalState>? states;

  factory DbcSignal.fromRawJson(String str) => DbcSignal.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DbcSignal.fromJson(Map<String, dynamic> json) => DbcSignal(
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
    states: json["states"] == null ? null : List<DbcSignalState>.from(json["states"].map((x) => DbcSignalState.fromJson(x))),
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
      return value.toStringAsFixed(2);
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

  bool isInterestingSignal() {
    return !name.toLowerCase().contains('counter') && !name.toLowerCase().endsWith('bz') && !name.toLowerCase().contains('crc') && !name.toLowerCase().contains('checksum');
  }
}