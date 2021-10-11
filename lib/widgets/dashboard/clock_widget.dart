
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';

import 'abstract_dashboard_widget.dart';

class ClockWidget extends AbstractDashboardWidget {
  ClockWidget(streamCanFrame) : super([Diagnosis01Frame], streamCanFrame);

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget> [
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
  void onNewValue(CanFrame frame) {
    DateTime newValue = (frame as Diagnosis01Frame).dateTime();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }

}