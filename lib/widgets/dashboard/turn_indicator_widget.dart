import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class TurnIndicatorWidget extends AbstractDashboardWidget {
  final TurnIndicatorDirection direction;

  TurnIndicatorWidget(streamVehicleState, this.direction) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _TurnIndicatorWidgetState();
  }
}

enum TurnIndicatorDirection {
  left,
  right
}

class _TurnIndicatorWidgetState extends AbstractDashboardWidgetState<TurnIndicatorWidget> {
  bool value = false;

  SvgPicture? valueOn;
  SvgPicture? valueOff;

  @override
  void initState() {
    super.initState();
    
    String assetName = '';
    if (widget.direction == TurnIndicatorDirection.left) {
      assetName = 'blinker_left';
    } else {
      assetName = 'blinker_right';
    }

    valueOn = SvgPicture.asset('assets/icons/$assetName.svg', width: 50, height: 50, color: Colors.green);
    valueOff = SvgPicture.asset('assets/icons/$assetName.svg', width: 50, height: 50, color: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return (value ? valueOn : valueOff) ?? SizedBox();
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    bool newValue = widget.direction == TurnIndicatorDirection.left ? vehicleState.lights.blinker.blinkerLeft : vehicleState.lights.blinker.blinkerRight;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}