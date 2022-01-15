import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class SpeedWidget extends AbstractDashboardWidget {
  SpeedWidget(streamCanFrame) : super([Combi01Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _SpeedWidgetState();
  }
}

class _SpeedWidgetState extends AbstractDashboardWidgetState<SpeedWidget> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$value",
          style: TextStyle(
            color: Colors.white,
            fontSize: 60,
            fontWeight: FontWeight.bold
          )
        ),
        Text(
          "Km/h",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w300
          )
        )
      ]
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    int newValue = (frame as Combi01Frame).speed();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}