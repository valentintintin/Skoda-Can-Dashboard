
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';

import 'abstract_dashboard_widget.dart';

class GazoilWidget extends AbstractDashboardWidget {
  GazoilWidget(streamCanFrame) : super([StationWagon02Frame, Combi01Frame], streamCanFrame);

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget> [
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
  void onNewValue(CanFrame frame) {
    int newValue = value;
    bool newEmptySoon = emptySoon;
    
    if (frame is StationWagon02Frame) {
      newValue = frame.contentTank();
    } else if (frame is Combi01Frame) {
      newEmptySoon = newValue == 0 || frame.isTankEmptySoon();
    }
    
    if (newValue != value || newEmptySoon != emptySoon) {
      setState(() {
        value = newValue;
        emptySoon = newEmptySoon;
      });
    }
  }
}