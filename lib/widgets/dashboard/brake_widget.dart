import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/motor_14_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class BrakeWidget extends AbstractDashboardWidget {
  BrakeWidget(streamCanFrame) : super([Motor14Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _BrakeWidgetState();
  }
}

class _BrakeWidgetState extends AbstractDashboardWidgetState<BrakeWidget> {
  bool value = false;

  SvgPicture iconEnabled = SvgPicture.asset('assets/icons/air_pressure.svg', width: 50, height: 50, color: Colors.green);
  SvgPicture iconDisabled = SvgPicture.asset('assets/icons/air_pressure.svg', width: 50, height: 50, color: Colors.grey.withOpacity(0.5));
  
  @override
  Widget build(BuildContext context) {
    return value ? iconEnabled : iconDisabled;
  }

  @override
  void onNewValue(CanFrame frame) {
    bool newValue = (frame as Motor14Frame).isBraking();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}