import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class TemperatureOutsideWidget extends AbstractDashboardWidget {
  TemperatureOutsideWidget(streamVehicleState) : super(streamVehicleState);

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
      children: [
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
  void onNewValue(VehicleState vehicleState) {
    String newValue = vehicleState.sensors.temperatureOutside.toStringAsFixed(1);
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}