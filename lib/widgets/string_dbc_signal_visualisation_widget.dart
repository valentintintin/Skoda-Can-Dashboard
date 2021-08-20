import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';

class StringDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const StringDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal })
      : super(key: key);

  @override
  _StringDbcSignalVisualisationWidgetState createState() => _StringDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _StringDbcSignalVisualisationWidgetState extends State<StringDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  String value = '0';

  _StringDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        value = dbcSignal.getValueFromBitesAsString(event.bits);
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text(dbcSignal.name + '\n[' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
          Text(value + (dbcSignal.postfixMetric != null ? ' ' + dbcSignal.postfixMetric! : ''), style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
        ]
    );
  }
}