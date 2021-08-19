import 'dart:convert';

import 'dbc_signal.dart';

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
  final List<DbcSignal> signals;

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
    signals: List<DbcSignal>.from(json["signals"].map((x) => DbcSignal.fromJson(x))),
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