import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class KilometersWidget extends AbstractDashboardWidget {
  KilometersWidget(streamVehicleState) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _KilometersWidgetState();
  }
}

class _KilometersWidgetState extends AbstractDashboardWidgetState<KilometersWidget> {
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Text(
        "$value Km",
        style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w300
        )
    );
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    int newValue = vehicleState.kilometer;
    
    if (newValue > value) {
      setState(() {
        value = newValue;
      });
    }
  }

}