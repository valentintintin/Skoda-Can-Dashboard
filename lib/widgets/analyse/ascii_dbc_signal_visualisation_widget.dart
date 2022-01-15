import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';

class AsciiDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const AsciiDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal })
      : super(key: key);

  @override
  _AsciiDbcSignalVisualisationWidgetState createState() => _AsciiDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _AsciiDbcSignalVisualisationWidgetState extends State<AsciiDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  String value = '';

  _AsciiDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

  @override
  void initState() {
    super.initState();
    serialListening = streamFrame.listen((event) {
      if (event.canId == dbc.canId) {
        if (value.length >= 40) {
          value = '';
        }

        value += dbcSignal.asAscii(event.bits);
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
        children: [
          Text(dbcSignal.name + ' ASCII\n[' + dbc.name + ' 0x' + dbc.canId.toRadixString(16).padLeft(8, '0').toUpperCase() + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.orange)),
          Text(value, style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.orange)),
        ]
    );
  }
}
