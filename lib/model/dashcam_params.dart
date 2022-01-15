// To parse this JSON data, do
//
//     dashcamParams = dashcamParamsFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class DashcamParams {
  DashcamParams({
    required this.result,
    required this.resizePercent,
    required this.rotationAngle,
    required this.gaussianBlur,
    required this.canny,
    required this.lanes,
    required this.panels,
  });

  String result;
  int resizePercent;
  int rotationAngle;
  int gaussianBlur;
  Canny canny;
  Lanes lanes;
  Panels panels;

  factory DashcamParams.fromRawJson(String str) => DashcamParams.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DashcamParams.fromJson(Map<String, dynamic> json) => DashcamParams(
    result: json["result"],
    resizePercent: json["resize_percent"],
    rotationAngle: json["rotation_angle"],
    gaussianBlur: json["gaussian_blur"],
    canny: Canny.fromJson(json["canny"]),
    lanes: Lanes.fromJson(json["lanes"]),
    panels: Panels.fromJson(json["panels"]),
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "resize_percent": resizePercent,
    "rotation_angle": rotationAngle,
    "gaussian_blur": gaussianBlur,
    "canny": canny.toJson(),
    "lanes": lanes.toJson(),
    "panels": panels.toJson(),
  };
}

class Canny {
  Canny({
    required this.lowThreshold,
    required this.highThreshold,
  });

  int lowThreshold;
  int highThreshold;

  factory Canny.fromRawJson(String str) => Canny.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Canny.fromJson(Map<String, dynamic> json) => Canny(
    lowThreshold: json["low_threshold"],
    highThreshold: json["high_threshold"],
  );

  Map<String, dynamic> toJson() => {
    "low_threshold": lowThreshold,
    "high_threshold": highThreshold,
  };
}

class Lanes {
  Lanes({
    required this.lengthMultiplier,
    required this.polygonMultiplier,
    required this.houghLines,
    required this.angle,
    required this.drawing,
  });

  double lengthMultiplier;
  PolygonMultiplier polygonMultiplier;
  HoughLines houghLines;
  LanesAngle angle;
  LanesDrawing drawing;

  factory Lanes.fromRawJson(String str) => Lanes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Lanes.fromJson(Map<String, dynamic> json) => Lanes(
    lengthMultiplier: json["length_multiplier"].toDouble(),
    polygonMultiplier: PolygonMultiplier.fromJson(json["polygon_multiplier"]),
    houghLines: HoughLines.fromJson(json["hough_lines"]),
    angle: LanesAngle.fromJson(json["angle"]),
    drawing: LanesDrawing.fromJson(json["drawing"]),
  );

  Map<String, dynamic> toJson() => {
    "length_multiplier": lengthMultiplier,
    "polygon_multiplier": polygonMultiplier.toJson(),
    "hough_lines": houghLines.toJson(),
    "angle": angle.toJson(),
    "drawing": drawing.toJson(),
  };
}

class LanesAngle {
  LanesAngle({
    required this.center,
    required this.interval,
  });

  int center;
  int interval;

  factory LanesAngle.fromRawJson(String str) => LanesAngle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LanesAngle.fromJson(Map<String, dynamic> json) => LanesAngle(
    center: json["center"],
    interval: json["interval"],
  );

  Map<String, dynamic> toJson() => {
    "center": center,
    "interval": interval,
  };
}

class LanesDrawing {
  LanesDrawing({
    required this.lanes,
    required this.angle,
  });

  LanesClass lanes;
  DrawingAngle angle;

  factory LanesDrawing.fromRawJson(String str) => LanesDrawing.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LanesDrawing.fromJson(Map<String, dynamic> json) => LanesDrawing(
    lanes: LanesClass.fromJson(json["lanes"]),
    angle: DrawingAngle.fromJson(json["angle"]),
  );

  Map<String, dynamic> toJson() => {
    "lanes": lanes.toJson(),
    "angle": angle.toJson(),
  };
}

class DrawingAngle {
  DrawingAngle({
    required this.color,
    required this.colorAlert,
    required this.thickness,
  });

  List<int> color;
  List<int> colorAlert;
  int thickness;

  factory DrawingAngle.fromRawJson(String str) => DrawingAngle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DrawingAngle.fromJson(Map<String, dynamic> json) => DrawingAngle(
    color: List<int>.from(json["color"].map((x) => x)),
    colorAlert: List<int>.from(json["color_alert"].map((x) => x)),
    thickness: json["thickness"],
  );

  Map<String, dynamic> toJson() => {
    "color": List<dynamic>.from(color.map((x) => x)),
    "color_alert": List<dynamic>.from(colorAlert.map((x) => x)),
    "thickness": thickness,
  };
}

class LanesClass {
  LanesClass({
    required this.color,
    required this.thickness,
  });

  List<int> color;
  int thickness;

  factory LanesClass.fromRawJson(String str) => LanesClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LanesClass.fromJson(Map<String, dynamic> json) => LanesClass(
    color: List<int>.from(json["color"].map((x) => x)),
    thickness: json["thickness"],
  );

  Map<String, dynamic> toJson() => {
    "color": List<dynamic>.from(color.map((x) => x)),
    "thickness": thickness,
  };
}

class HoughLines {
  HoughLines({
    required this.threshold,
    required this.minLineLength,
    required this.maxLineGap,
  });

  int threshold;
  int minLineLength;
  int maxLineGap;

  factory HoughLines.fromRawJson(String str) => HoughLines.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HoughLines.fromJson(Map<String, dynamic> json) => HoughLines(
    threshold: json["threshold"],
    minLineLength: json["min_line_length"],
    maxLineGap: json["max_line_gap"],
  );

  Map<String, dynamic> toJson() => {
    "threshold": threshold,
    "min_line_length": minLineLength,
    "max_line_gap": maxLineGap,
  };
}

class PolygonMultiplier {
  PolygonMultiplier({
    required this.bottomLeft,
    required this.topLeft,
    required this.bottomRight,
    required this.topRight,
  });

  List<double> bottomLeft;
  List<double> topLeft;
  List<double> bottomRight;
  List<double> topRight;

  factory PolygonMultiplier.fromRawJson(String str) => PolygonMultiplier.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PolygonMultiplier.fromJson(Map<String, dynamic> json) => PolygonMultiplier(
    bottomLeft: List<double>.from(json["bottom_left"].map((x) => x.toDouble())),
    topLeft: List<double>.from(json["top_left"].map((x) => x.toDouble())),
    bottomRight: List<double>.from(json["bottom_right"].map((x) => x.toDouble())),
    topRight: List<double>.from(json["top_right"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "bottom_left": List<dynamic>.from(bottomLeft.map((x) => x)),
    "top_left": List<dynamic>.from(topLeft.map((x) => x)),
    "bottom_right": List<dynamic>.from(bottomRight.map((x) => x)),
    "top_right": List<dynamic>.from(topRight.map((x) => x)),
  };
}

class Panels {
  Panels({
    required this.polygonMultiplier,
    required this.sizeDetection,
    required this.drawing,
  });

  PolygonMultiplier polygonMultiplier;
  SizeDetection sizeDetection;
  LanesClass drawing;

  factory Panels.fromRawJson(String str) => Panels.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Panels.fromJson(Map<String, dynamic> json) => Panels(
    polygonMultiplier: PolygonMultiplier.fromJson(json["polygon_multiplier"]),
    sizeDetection: SizeDetection.fromJson(json["size_detection"]),
    drawing: LanesClass.fromJson(json["drawing"]),
  );

  Map<String, dynamic> toJson() => {
    "polygon_multiplier": polygonMultiplier.toJson(),
    "size_detection": sizeDetection.toJson(),
    "drawing": drawing.toJson(),
  };
}

class SizeDetection {
  SizeDetection({
    required this.width,
    required this.height,
    required this.ratio,
  });

  MinMax width;
  MinMax height;
  MinMaxDouble ratio;

  factory SizeDetection.fromRawJson(String str) => SizeDetection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SizeDetection.fromJson(Map<String, dynamic> json) => SizeDetection(
    width: MinMax.fromJson(json["width"]),
    height: MinMax.fromJson(json["height"]),
    ratio: MinMaxDouble.fromJson(json["ratio"]),
  );

  Map<String, dynamic> toJson() => {
    "width": width.toJson(),
    "height": height.toJson(),
    "ratio": ratio.toJson(),
  };
}

class MinMax {
  MinMax({
    required this.min,
    required this.max,
  });

  int min;
  int max;

  factory MinMax.fromRawJson(String str) => MinMax.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MinMax.fromJson(Map<String, dynamic> json) => MinMax(
    min: json["min"],
    max: json["max"],
  );

  Map<String, dynamic> toJson() => {
    "min": min,
    "max": max,
  };
}

class MinMaxDouble {
  MinMaxDouble({
    required this.min,
    required this.max,
  });

  double min;
  double max;

  factory MinMaxDouble.fromRawJson(String str) => MinMaxDouble.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MinMaxDouble.fromJson(Map<String, dynamic> json) => MinMaxDouble(
    min: json["min"].toDouble(),
    max: json["max"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "min": min,
    "max": max,
  };
}
