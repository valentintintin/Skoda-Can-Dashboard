import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class HandbrakeWidget extends AbstractDashboardWidget {
  HandbrakeWidget(streamCanFrame) : super([Combi01Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _HandbrakeWidgetState();
  }
}

class _HandbrakeWidgetState extends AbstractDashboardWidgetState<HandbrakeWidget> {
  bool value = false;

  SvgPicture iconEnabled = SvgPicture.asset('assets/icons/parking_brakes.svg', width: 50, height: 50, color: Colors.green);
  SvgPicture iconDisabled = SvgPicture.asset('assets/icons/parking_brakes.svg', width: 50, height: 50, color: Colors.grey.withOpacity(0.5));
  
  @override
  Widget build(BuildContext context) {
    return value ? iconEnabled : iconDisabled;
  }
  
  @override
  void onNewValue(CanFrame frame) {
    bool newValue = (frame as Combi01Frame).isHandbrakeEngaged();
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}