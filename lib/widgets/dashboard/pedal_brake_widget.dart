
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/pedal_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class PedalBrakeWidget extends AbstractDashboardWidget {
  PedalBrakeWidget(streamCanFrame) : super([PedalFrame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _PedalBrakeWidgetState();
  }
}

class _PedalBrakeWidgetState extends AbstractDashboardWidgetState<PedalBrakeWidget> {
  String value = '0';

  @override
  Widget build(BuildContext context) {
    return Text(
        value,
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    String newValue = (frame as PedalFrame).brakePedalIntensity().toString();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}