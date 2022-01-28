import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class PedalBrakeWidget extends AbstractDashboardWidget {
  PedalBrakeWidget(streamVehicleState) : super(streamVehicleState);

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
  void onNewValue(VehicleState vehicleState) {
    String newValue = vehicleState.driving.brake.pedalIntensity.toString();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}