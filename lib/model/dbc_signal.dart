import 'dart:convert';

import 'package:bit_array/bit_array.dart';
import 'package:skoda_can_dashboard/model/signal.dart';

import 'signal_state.dart';

class DbcSignal extends Signal {
  DbcSignal({
    required this.name,
    required this.label,
    required startBit,
    required bitLength,
    required isLittleEndian,
    required isSigned,
    required double? factor,
    required double? offset,
    required this.min,
    required this.max,
    required this.states,
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
  }) : super(startBit, bitLength,
      isLittleEndian: isLittleEndian,
      isSigned: isSigned,
      factor: factor,
      offset: offset,
  );

  final String name;
  final String label;
  final String dataType;
  final double min;
  final double max;
  final String? sourceUnit;
  final String? postfixMetric;
  final bool choking;
  final bool visibility;
  final int interval;
  final String category;
  final String? comment;
  final int lineInDbc;
  final List<String> problems;
  final List<SignalState>? states;

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
    states: json["states"] == null ? null : List<SignalState>.from(json["states"].map((x) => SignalState.fromJson(x))),
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
  
  String getValueFromBitesAsString(BitArray bits) {
    double value = asDouble(bits);

    try {
      return states!.firstWhere((element) => element.value == value).state;
    } catch (e) {
      return value.toStringAsFixed(2);
    }
  }
  
  bool isInterestingSignal() {
    return !name.toLowerCase().contains('counter') && !name.toLowerCase().endsWith('bz') && !name.toLowerCase().contains('crc') && !name.toLowerCase().contains('checksum');
  }
}

enum SignalType {
  int,
}