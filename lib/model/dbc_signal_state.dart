import 'dart:convert';

class DbcSignalState {
  DbcSignalState({
    required this.value,
    required this.state,
  });

  final double value;
  final String state;

  factory DbcSignalState.fromRawJson(String str) => DbcSignalState.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DbcSignalState.fromJson(Map<String, dynamic> json) => DbcSignalState(
    value: json["value"].toDouble(),
    state: json["state"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "state": state,
  };
}
