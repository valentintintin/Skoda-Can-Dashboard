import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class ClimAcWidget extends AbstractDashboardWidget {
  ClimAcWidget(streamVehicleState) : super(streamVehicleState);

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
  void onNewValue(VehicleState vehicleState) {
    bool newValue = vehicleState.ventilation.airConditionner;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}