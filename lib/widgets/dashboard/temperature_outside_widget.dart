
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/gateway_72_frame.dart';
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class TemperatureOutsideWidget extends AbstractDashboardWidget {
  TemperatureOutsideWidget(streamCanFrame) : super([StationWagon02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _TemperatureOutsideWidgetState();
  }
}

class _TemperatureOutsideWidgetState extends AbstractDashboardWidgetState<TemperatureOutsideWidget> {
  String value = '0';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget> [
        Text(
          "$value °C EXT",
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
    String newValue = value;

    if (frame is Gateway72Frame) {
      // Gateway72Frame possible but not always the same as StationWagon (sometime 2°C delta)
      newValue = frame.temperatureOutside().toStringAsFixed(1);
    } else if (frame is StationWagon02Frame) {
      newValue = frame.temperatureOutside().toStringAsFixed(1);
    }
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}