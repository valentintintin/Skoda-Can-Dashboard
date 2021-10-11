
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/acc_02_frame.dart';

import 'abstract_dashboard_widget.dart';

class AccDistanceWidget extends AbstractDashboardWidget {
  AccDistanceWidget(streamCanFrame) : super([Acc02Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() {
    return _AccDistanceWidgetState();
  }
}

class _AccDistanceWidgetState extends AbstractDashboardWidgetState<AccDistanceWidget> {
  int value = 0;
  bool hasObject = false;
  bool isImportant = false;

  Image imageSkoda = Image(image: AssetImage('assets/images/fabia.png'));
  Image imageTesla = Image(image: AssetImage('assets/images/tesla.png'));

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List.filled((Acc02Frame.MAX_SPEED + 2) ~/ 10, SizedBox(width: 25));

    widgets.first = Padding(
      padding: const EdgeInsets.all(8.0),
      child: imageSkoda,
    );

    if (hasObject) {
      widgets[(value + 1) ~/ 2] = Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
            "$value m",
            style: TextStyle(
              color: isImportant ? Colors.red : Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w400,
            )
        ),
      );
      widgets[value + 1] = Padding(
        padding: const EdgeInsets.all(8.0),
        child: imageTesla,
      );
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    Acc02Frame accFrame = frame as Acc02Frame;
    
    bool newHasObject = accFrame.isObjectDetected();
    int newValue = accFrame.distanceObject(); 
    
    if (newValue != value || newHasObject != hasObject) {
      setState(() {
        hasObject = newHasObject;
        value = newValue;
      });
    }
  }
}