import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';

class RawSerialPage extends StatefulWidget {
  @override
  _RawSerialPageState createState() => _RawSerialPageState();
}

class _RawSerialPageState extends State<RawSerialPage> {
  StreamSubscription? serialListening;

  Map<String, CanFrame> frames = new Map();

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial!.listen((event) {
      frames[event.canId] = event;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    serialListening?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, CanFrame>> framesSorted = frames.entries.toList();
    framesSorted.sort((a, b) => a.key.compareTo(b.key));

    List<Widget> childrens = List.empty(growable: true);
    childrens.add(new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          new SizedBox(
              width: 80,
              child: new Text('Can ID', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B0', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B1', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B2', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B3', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B4', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B5', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B6', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 70,
              child: new Text('B7', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
          new SizedBox(
              width: 80,
              child: new Text('ASCII', style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold))
          ),
        ]
    ));

    childrens.addAll(framesSorted.map((entry) {
      List<Widget> columnsFrame = List.empty(growable: true);

      Dbc? dbc;

      try {
        dbc = dbcs.firstWhere((element) => element.canId == entry.key);
      } catch(e) {}

      columnsFrame.add(new SizedBox(
          width: 80,
          child: new Text(entry.key.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold),)
      ));
      entry.value.bytes.forEach((element) => columnsFrame.add(new SizedBox(
          width: 70,
          child: new Text(element.toRadixString(16).toUpperCase().padLeft(2, '0') + ' (' + element.toString() + ')'))
      ));
      columnsFrame.add(new SizedBox(
          width: 80,
          child: new Text(entry.value.bytesToAsciiString())
      ));


      List<Widget> columnsRow = List.empty(growable: true);
      columnsRow.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columnsFrame,
      ));

      if (dbc?.signals.isNotEmpty == true) {
        columnsRow.add(new Text(dbc!.name, style: TextStyle(fontWeight: FontWeight.bold),));
        columnsRow.add(new Text(dbc.signals.where((signal) => signal.isInterestingSignal() && signal.comment != 'byte' && signal.comment != 'long').map((signal) => signal.name + ' : ' + signal.getValueFromBitesAsString(entry.value.bits) + (signal.postfixMetric != null ? ' ' + signal.postfixMetric! : '')).join('\n'),));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: columnsRow
      );
    }).toList());

    return ListView(
        padding: const EdgeInsets.all(8),
        children: childrens
    );
  }
}