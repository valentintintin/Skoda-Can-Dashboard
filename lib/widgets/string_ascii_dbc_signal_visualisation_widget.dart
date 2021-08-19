import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';

class StringAsciiDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const StringAsciiDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal })
      : super(key: key);

  @override
  _StringAsciiDbcSignalVisualisationWidgetState createState() => _StringAsciiDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _StringAsciiDbcSignalVisualisationWidgetState extends State<StringAsciiDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  String value = '';

  _StringAsciiDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

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
          Text(dbcSignal.name + ' [' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
        ]
    );
  }
}