import 'dart:convert';

class SignalState {
  SignalState({
    required this.value,
    required this.state,
  });

  final double value;
  final String state;

  factory SignalState.fromRawJson(String str) => SignalState.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SignalState.fromJson(Map<String, dynamic> json) => SignalState(
    value: json["value"].toDouble(),
    state: json["state"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "state": state,
  };
  
  int asInt() => int.parse(state);
  double asDouble() => double.parse(state);
}
