
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/engine_04_frame.dart';

import 'abstract_dashboard_widget.dart';

class RpmGaugeWidget extends AbstractDashboardWidget {
  RpmGaugeWidget(streamCanFrame) : super([Engine04Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _RpmGaugeWidgetState();
  }
}

class _RpmGaugeWidgetState extends AbstractDashboardWidgetState<RpmGaugeWidget> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value RPM",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w400
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    int newValue = (frame as Engine04Frame).engineSpeed();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}