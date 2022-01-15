
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/blinkmodi_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class TurnIndicatorWidget extends AbstractDashboardWidget {
  final TurnIndicatorDirection direction;

  TurnIndicatorWidget(streamCanFrame, this.direction) : super([Blinkmodi02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _TurnIndicatorWidgetState();
  }
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
  void onNewValue(CanFrame frame) {
    bool newValue = (frame as Blinkmodi02Frame).isTurnIndicatorActivated(widget.direction);
    
    if (newValue != value) {
      setState(() {
        value = newValue;
      });
    }
  }
}