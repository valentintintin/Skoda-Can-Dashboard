import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class BrakeWidget extends AbstractDashboardWidget {
  BrakeWidget(streamVehicleState) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _BrakeWidgetState();
  }
}

class _BrakeWidgetState extends AbstractDashboardWidgetState<BrakeWidget> {
  bool valueBrake = false;
  bool valueHandBrake = false;

  SvgPicture iconHandBrake = SvgPicture.asset('assets/icons/brakes.svg', width: 50, height: 50, color: Colors.red);
  SvgPicture iconBrake = SvgPicture.asset('assets/icons/brakes.svg', width: 50, height: 50, color: Colors.orange);
  SvgPicture iconDisabled = SvgPicture.asset('assets/icons/brakes.svg', width: 50, height: 50, color: Colors.grey.withOpacity(0.5));
  
  @override
  Widget build(BuildContext context) {
    return valueHandBrake ? iconHandBrake : valueBrake ? iconBrake : iconDisabled;
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    bool newValueBrake = vehicleState.driving.brake.braking;
    bool newValueHandBrake = vehicleState.driving.brake.handbrake;
    
    if (newValueBrake != valueBrake || newValueHandBrake != valueHandBrake) {
      setState(() {
        valueBrake = newValueBrake;
        valueHandBrake = newValueHandBrake;
      });
    }
  }
}