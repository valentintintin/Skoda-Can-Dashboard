import 'dart:convert';

class VehicleState {
  VehicleState({
    required this.driving,
    required this.lights,
    required this.sensors,
    required this.tank,
    required this.ventilation,
    required this.adaptiveCruiseControl,
    required this.dateTime,
    required this.kilometer,
  });

  final Driving driving;
  final Lights lights;
  final Sensors sensors;
  final Tank tank;
  final Ventilation ventilation;
  final AdaptiveCruiseControl adaptiveCruiseControl;
  final DateTime dateTime;
  final int kilometer;

  factory VehicleState.fromJson(String str) => VehicleState.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VehicleState.fromMap(Map<String, dynamic> json) => VehicleState(
    driving: Driving.fromMap(json["Driving"]),
    lights: Lights.fromMap(json["Lights"]),
    sensors: Sensors.fromMap(json["Sensors"]),
    tank: Tank.fromMap(json["Tank"]),
    ventilation: Ventilation.fromMap(json["Ventilation"]),
    adaptiveCruiseControl: AdaptiveCruiseControl.fromMap(json["AdaptiveCruiseControl"]),
    dateTime: DateTime.parse(json["DateTime"]),
    kilometer: json["Kilometer"],
  );

  Map<String, dynamic> toMap() => {
    "Driving": driving.toMap(),
    "Lights": lights.toMap(),
    "Sensors": sensors.toMap(),
    "Tank": tank.toMap(),
    "Ventilation": ventilation.toMap(),
    "AdaptiveCruiseControl": adaptiveCruiseControl.toMap(),
    "DateTime": dateTime.toIso8601String(),
    "Kilometer": kilometer,
  };
}

class AdaptiveCruiseControl {
  AdaptiveCruiseControl({
    required this.active,
    required this.objectDetected,
    required this.objectDistance,
    required this.desiredSpeed,
  });

  final bool active;
  final bool objectDetected;
  final int objectDistance;
  final int desiredSpeed;

  factory AdaptiveCruiseControl.fromJson(String str) => AdaptiveCruiseControl.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdaptiveCruiseControl.fromMap(Map<String, dynamic> json) => AdaptiveCruiseControl(
    active: json["Active"],
    objectDetected: json["ObjectDetected"],
    objectDistance: json["ObjectDistance"],
    desiredSpeed: json["DesiredSpeed"],
  );

  Map<String, dynamic> toMap() => {
    "Active": active,
    "ObjectDetected": objectDetected,
    "ObjectDistance": objectDistance,
    "DesiredSpeed": desiredSpeed,
  };
}

class Driving {
  Driving({
    required this.speed,
    required this.engineRunning,
    required this.throttlePedalIntensity,
    required this.brake,
    required this.gear,
  });

  final int speed;
  final bool engineRunning;
  final int throttlePedalIntensity;
  final Brake brake;
  final Gear gear;

  factory Driving.fromJson(String str) => Driving.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Driving.fromMap(Map<String, dynamic> json) => Driving(
    speed: json["Speed"],
    engineRunning: json["EngineRunning"],
    throttlePedalIntensity: json["ThrottlePedalIntensity"],
    brake: Brake.fromMap(json["Brake"]),
    gear: Gear.fromMap(json["Gear"]),
  );

  Map<String, dynamic> toMap() => {
    "Speed": speed,
    "EngineRunning": engineRunning,
    "ThrottlePedalIntensity": throttlePedalIntensity,
    "Brake": brake.toMap(),
    "Gear": gear.toMap(),
  };
}

class Brake {
  Brake({
    required this.handbrake,
    required this.braking,
    required this.emergencyBrake,
    required this.pedalIntensity,
  });

  final bool handbrake;
  final bool braking;
  final bool emergencyBrake;
  final int pedalIntensity;

  factory Brake.fromJson(String str) => Brake.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Brake.fromMap(Map<String, dynamic> json) => Brake(
    handbrake: json["Handbrake"],
    braking: json["Braking"],
    emergencyBrake: json["EmergencyBrake"],
    pedalIntensity: json["PedalIntensity"],
  );

  Map<String, dynamic> toMap() => {
    "Handbrake": handbrake,
    "Braking": braking,
    "EmergencyBrake": emergencyBrake,
    "PedalIntensity": pedalIntensity,
  };
}

class Gear {
  Gear({
    required this.level,
    required this.mode,
  });

  final String level;
  final String mode;

  factory Gear.fromJson(String str) => Gear.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Gear.fromMap(Map<String, dynamic> json) => Gear(
    level: json["Level"],
    mode: json["Mode"],
  );

  Map<String, dynamic> toMap() => {
    "Level": level,
    "Mode": mode,
  };
}

class Lights {
  Lights({
    required this.blinker,
  });

  final Blinker blinker;

  factory Lights.fromJson(String str) => Lights.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Lights.fromMap(Map<String, dynamic> json) => Lights(
    blinker: Blinker.fromMap(json["Blinker"]),
  );

  Map<String, dynamic> toMap() => {
    "Blinker": blinker.toMap(),
  };
}

class Blinker {
  Blinker({
    required this.blinkerLeft,
    required this.blinkerRight,
  });

  final bool blinkerLeft;
  final bool blinkerRight;

  factory Blinker.fromJson(String str) => Blinker.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Blinker.fromMap(Map<String, dynamic> json) => Blinker(
    blinkerLeft: json["BlinkerLeft"],
    blinkerRight: json["BlinkerRight"],
  );

  Map<String, dynamic> toMap() => {
    "BlinkerLeft": blinkerLeft,
    "BlinkerRight": blinkerRight,
  };
}

class Sensors {
  Sensors({
    required this.transverseAcceleration,
    required this.lateralAcceleration,
    required this.engineChargePressure,
    required this.engineSpeed,
    required this.temperatureOutside,
  });

  final double transverseAcceleration;
  final double lateralAcceleration;
  final double engineChargePressure;
  final int engineSpeed;
  final double temperatureOutside;

  factory Sensors.fromJson(String str) => Sensors.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Sensors.fromMap(Map<String, dynamic> json) => Sensors(
    transverseAcceleration: json["TransverseAcceleration"].toDouble(),
    lateralAcceleration: json["LateralAcceleration"].toDouble(),
    engineChargePressure: json["EngineChargePressure"].toDouble(),
    engineSpeed: json["EngineSpeed"],
    temperatureOutside: json["TemperatureOutside"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "TransverseAcceleration": transverseAcceleration,
    "LateralAcceleration": lateralAcceleration,
    "EngineChargePressure": engineChargePressure,
    "EngineSpeed": engineSpeed,
    "TemperatureOutside": temperatureOutside,
  };
}

class Tank {
  Tank({
    required this.low,
    required this.currentCapacity,
    required this.capacity,
  });

  final bool low;
  final int currentCapacity;
  final int capacity;

  factory Tank.fromJson(String str) => Tank.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Tank.fromMap(Map<String, dynamic> json) => Tank(
    low: json["Low"],
    currentCapacity: json["CurrentCapacity"],
    capacity: json["Capacity"],
  );

  Map<String, dynamic> toMap() => {
    "Low": low,
    "CurrentCapacity": currentCapacity,
    "Capacity": capacity,
  };
}

class Ventilation {
  Ventilation({
    required this.airConditionner,
    required this.intensity,
  });

  final bool airConditionner;
  final int intensity;

  factory Ventilation.fromJson(String str) => Ventilation.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Ventilation.fromMap(Map<String, dynamic> json) => Ventilation(
    airConditionner: json["AirConditionner"],
    intensity: json["Intensity"],
  );

  Map<String, dynamic> toMap() => {
    "AirConditionner": airConditionner,
    "Intensity": intensity,
  };
}
