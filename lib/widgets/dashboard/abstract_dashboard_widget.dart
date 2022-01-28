import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';

abstract class AbstractDashboardWidget extends StatefulWidget {
  final Stream<VehicleState> streamVehicleState;
  
  AbstractDashboardWidget(this.streamVehicleState);
}

abstract class AbstractDashboardWidgetState<T extends AbstractDashboardWidget> extends State<T> {
  late StreamSubscription<VehicleState> _subscriptionVehicleState;
  
  @override
  void initState() {
    super.initState();
    _subscriptionVehicleState = widget.streamVehicleState.asBroadcastStream().listen((vehicleState) {
      onNewValue(vehicleState);
    });
  }
  
  @override
  void dispose() {
    _subscriptionVehicleState.cancel();
    super.dispose();
  }
  
  void onNewValue(VehicleState vehicleState);
}