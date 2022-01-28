import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class GazoilWidget extends AbstractDashboardWidget {
  GazoilWidget(streamVehicleState) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _GazoilWidgetState();
  }
}

class _GazoilWidgetState extends AbstractDashboardWidgetState<GazoilWidget> {
  int value = 0;
  bool emptySoon = false;

  SvgPicture iconFull = SvgPicture.asset('assets/icons/fuel.svg', width: 30, height: 30, color: Colors.blueGrey);
  SvgPicture iconEmpty = SvgPicture.asset('assets/icons/fuel.svg', width: 30, height: 30, color: Colors.red);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$value L",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w300
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: emptySoon ? iconEmpty : iconFull,
        )
      ]
    );
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    int newValue = vehicleState.tank.currentCapacity;
    bool newEmptySoon = newValue == 0 || vehicleState.tank.low;
    
    if (newValue != value || newEmptySoon != emptySoon) {
      setState(() {
        value = newValue;
        emptySoon = newEmptySoon;
      });
    }
  }
}