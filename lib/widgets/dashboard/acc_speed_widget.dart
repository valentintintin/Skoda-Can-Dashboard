
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/acc_02_frame.dart';

import 'abstract_dashboard_widget.dart';

class AccSpeedWidget extends AbstractDashboardWidget {
  AccSpeedWidget(streamCanFrame) : super([Acc02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _AccSpeedWidgetState();
  }
}

class _AccSpeedWidgetState extends AbstractDashboardWidgetState<AccSpeedWidget> {
  int value = 0;
  bool enabled = false;

  SvgPicture iconEnabled = SvgPicture.asset('assets/icons/cruise_control.svg', width: 50, height: 50, color: Colors.green);
  SvgPicture iconDisabled = SvgPicture.asset('assets/icons/cruise_control.svg', width: 50, height: 50, color: Colors.grey.withOpacity(0.5));

  @override
  Widget build(BuildContext context) {
    if (value >= 30) {
      return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "$value Km/h",
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white.withOpacity(
                        0.5),
                    fontSize: 35,
                    fontWeight: enabled ? FontWeight.w400 : FontWeight.w100,
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: enabled ? iconEnabled : iconDisabled,
            ),
          ]
      );
    }
    
    return SizedBox();
  }

  @override
  void onNewValue(CanFrame frame) {
    Acc02Frame accFrame = frame as Acc02Frame;
    
    bool newEnabled = accFrame.isSpeedEnabled();
    int newValue = accFrame.desiredSpeed();
    
    if (newValue != value || newEnabled != enabled) {
      setState(() {
        value = newValue;
        enabled = newEnabled;
      });
    }
  }
}