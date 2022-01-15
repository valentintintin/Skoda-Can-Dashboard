import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';

abstract class AbstractDashboardWidget extends StatefulWidget {
  final List<Type> typesFrames;
  final Stream<CanFrame> streamCanFrame;
  
  AbstractDashboardWidget(this.typesFrames, this.streamCanFrame);
}

abstract class AbstractDashboardWidgetState<T extends AbstractDashboardWidget> extends State<T> {
  late StreamSubscription<CanFrame> _subscriptionCanFrame;
  
  @override
  void initState() {
    super.initState();
    _subscriptionCanFrame = widget.streamCanFrame.asBroadcastStream().where((frame) => widget.typesFrames.contains(frame.runtimeType)).listen((frame) {
      onNewValue(frame);
    });
  }
  
  @override
  void dispose() {
    _subscriptionCanFrame.cancel();
    super.dispose();
  }
  
  void onNewValue(CanFrame frame);
}