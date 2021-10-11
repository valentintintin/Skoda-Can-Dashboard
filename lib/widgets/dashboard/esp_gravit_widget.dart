
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/esp_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class EspGravitWidget extends AbstractDashboardWidget {
  EspGravitWidget(streamCanFrame) : super([Esp02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _EspGravitWidgetState();
  }
}

class _EspGravitWidgetState extends AbstractDashboardWidgetState<EspGravitWidget> {
  String value = '0';

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value G",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    String newValue = (frame as Esp02Frame).transverseAcceleration().toStringAsFixed(2);
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}