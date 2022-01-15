
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/esp_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class EspYawWidget extends AbstractDashboardWidget {
  EspYawWidget(streamCanFrame) : super([Esp02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _EspYawWidgetState();
  }
}

class _EspYawWidgetState extends AbstractDashboardWidgetState<EspYawWidget> {
  String value = '0';

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value \"°Arc",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    String newValue = (frame as Esp02Frame).yawRate().toStringAsFixed(3);
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}