
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climatronic_frame.dart';

import 'abstract_dashboard_widget.dart';

class ClimSpeedWidget extends AbstractDashboardWidget {
  ClimSpeedWidget(streamCanFrame) : super([ClimatronicFrame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _ClimSpeedWidgetState();
  }
}

class _ClimSpeedWidgetState extends AbstractDashboardWidgetState<ClimSpeedWidget> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return value > 0 ? Text(
        "Vits $value",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    ) : SizedBox();
  }

  @override
  void onNewValue(CanFrame frame) {
    int newValue = (frame as ClimatronicFrame).speed();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}