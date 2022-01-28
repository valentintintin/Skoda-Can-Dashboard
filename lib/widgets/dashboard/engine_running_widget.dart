import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class EngineRunningWidget extends AbstractDashboardWidget {
  EngineRunningWidget(streamVehicleState) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _EngineRunningWidgetState();
  }
}

class _EngineRunningWidgetState extends AbstractDashboardWidgetState<EngineRunningWidget> {
  bool value = false;

  SvgPicture iconEnabled = SvgPicture.asset('assets/icons/engine.svg', width: 50, height: 50, color: Colors.green);
  SvgPicture iconDisabled = SvgPicture.asset('assets/icons/engine.svg', width: 50, height: 50, color: Colors.grey.withOpacity(0.5));

  @override
  Widget build(BuildContext context) {
    return value ? iconEnabled : iconDisabled;
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    bool newValue = vehicleState.driving.engineRunning;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}