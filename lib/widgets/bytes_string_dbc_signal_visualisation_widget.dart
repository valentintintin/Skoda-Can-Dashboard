import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';

class BytesStringDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;

  const BytesStringDbcSignalVisualisationWidget({ Key? key, required this.dbc })
      : super(key: key);

  @override
  _BytesStringDbcSignalVisualisationWidgetState createState() => _BytesStringDbcSignalVisualisationWidgetState(dbc);
}

class _BytesStringDbcSignalVisualisationWidgetState extends State<BytesStringDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;

  String value = '';

  _BytesStringDbcSignalVisualisationWidgetState(this.dbc);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        if (value.length >= 150) {
          value = '';
        }

        value += event.bytesToAsciiString();
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
          Text('ASCII [' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.green)),
          Text(value, style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.green)),
        ]
    );
  }
}