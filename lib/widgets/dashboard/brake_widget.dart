import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/motor_14_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class BrakeWidget extends AbstractDashboardWidget {
  BrakeWidget(streamCanFrame) : super([Motor14Frame, Combi01Frame], streamCanFrame);

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
  void onNewValue(CanFrame frame) {
    bool newValueBrake = valueBrake;
    bool newValueHandBrake = valueHandBrake;
    
    if (frame is Motor14Frame) {
      newValueBrake = frame.isBraking();
    } else if (frame is Combi01Frame) {
      newValueHandBrake = frame.isHandbrakeEngaged();
    }
    
    if (newValueBrake != valueBrake || newValueHandBrake != valueHandBrake) {
      setState(() {
        valueBrake = newValueBrake;
        valueHandBrake = newValueHandBrake;
      });
    }
  }
}