
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climate_11_frame.dart';

import 'abstract_dashboard_widget.dart';

class ClimAcWidget extends AbstractDashboardWidget {
  ClimAcWidget(streamCanFrame) : super([Climate11Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _ClimAcWidgetState();
  }
}

class _ClimAcWidgetState extends AbstractDashboardWidgetState<ClimAcWidget> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value ? 'AC' : '',
          style: TextStyle(
            color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w300
          )
        ),
      ]
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    bool newValue = (frame as Climate11Frame).isAcActivated();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}