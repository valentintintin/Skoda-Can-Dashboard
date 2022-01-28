import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class EspGravitWidget extends AbstractDashboardWidget {
  EspGravitWidget(streamVehicleState) : super(streamVehicleState);

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
  void onNewValue(VehicleState vehicleState) {
    String newValue = vehicleState.sensors.transverseAcceleration.toStringAsFixed(2);
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}