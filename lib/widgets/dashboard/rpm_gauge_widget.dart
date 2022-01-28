import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class RpmGaugeWidget extends AbstractDashboardWidget {
  RpmGaugeWidget(streamVehicleState) : super(streamVehicleState);

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
  void onNewValue(VehicleState vehicleState) {
    int newValue = vehicleState.sensors.engineSpeed;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}