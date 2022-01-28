import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

import 'abstract_dashboard_widget.dart';

class ClockWidget extends AbstractDashboardWidget {
  ClockWidget(streamVehicleState) : super(streamVehicleState);

  @override
  State<StatefulWidget> createState() {
    return _ClockWidgetState();
  }
}

class _ClockWidgetState extends AbstractDashboardWidgetState<ClockWidget> {
  DateTime value = DateTime.fromMillisecondsSinceEpoch(0);
  
  SvgPicture icon = SvgPicture.asset('assets/icons/time.svg', width: 30, height: 30, color: Colors.blueGrey);

  @override
  Widget build(BuildContext context) {
    String timeString = value.hour.toString().padLeft(2, '0') + ':' + value.minute.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            timeString,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w300
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: icon,
        )
      ]
    );
  }

  @override
  void onNewValue(VehicleState vehicleState) {
    DateTime newValue = vehicleState.dateTime;
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}