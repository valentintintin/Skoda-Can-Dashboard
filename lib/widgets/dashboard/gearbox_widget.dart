import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class GearboxWidget extends AbstractDashboardWidget {
  GearboxWidget(streamVehicleState) : super(streamVehicleState);

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
  void onNewValue(VehicleState vehicleState) {
    String newValue = vehicleState.driving.gear.mode + vehicleState.driving.gear.level;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}