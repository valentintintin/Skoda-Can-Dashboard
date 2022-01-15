
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/wba_03_frame.dart';

import 'abstract_dashboard_widget.dart';

class GearboxWidget extends AbstractDashboardWidget {
  GearboxWidget(streamCanFrame) : super([Wba03Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _GearboxWidgetState();
  }
}

class _GearboxWidgetState extends AbstractDashboardWidgetState<GearboxWidget> {
  String value = 'P';

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value",
        style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    Wba03Frame wbaFrame = frame as Wba03Frame;
    
    String newValue = wbaFrame.drivingMode() + wbaFrame.gear();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}