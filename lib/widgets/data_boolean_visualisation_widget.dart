import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';

class BooleanDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const BooleanDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal })
      : super(key: key);

  @override
  _BooleanDbcSignalVisualisationWidgetState createState() => _BooleanDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _BooleanDbcSignalVisualisationWidgetState extends State<BooleanDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  bool value = false;

  _BooleanDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial.listen((event) {
      if (event.canId == dbc.canId) {
        value = dbcSignal.asBoolean(event.bits);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    serialListening?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var stateWidget;

    if (value) {
      stateWidget = Icon(
        Icons.bolt,
        color: Colors.green,
        size: 60.0,
      );
    } else {
      stateWidget = Icon(
        Icons.power_settings_new,
        color: Colors.red,
        size: 60.0,
      );
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text(dbcSignal.name + '\n[' + dbcSignal.name + '\n[' + dbc.name + ' 0x' + dbc.canId.toRadixString(16).padLeft(8, '0').toUpperCase() + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
          stateWidget
        ]
    );
  }
}