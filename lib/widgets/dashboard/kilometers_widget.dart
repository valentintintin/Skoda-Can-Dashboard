
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';

import 'abstract_dashboard_widget.dart';

class KilometersWidget extends AbstractDashboardWidget {
  KilometersWidget(streamCanFrame) : super([StationWagon02Frame, Diagnosis01Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _KilometersWidgetState();
  }
}

class _KilometersWidgetState extends AbstractDashboardWidgetState<KilometersWidget> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value Km",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    int newValue = value;
    
    if (frame is StationWagon02Frame) {
      newValue = frame.kilometer();
    } else if (frame is Diagnosis01Frame) {
      newValue = frame.kilometer();
    }
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}