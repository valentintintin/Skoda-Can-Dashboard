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
  Map<String, List<ByteChange>> framesBytesChange = new Map();

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial!.listen((event) {
      if (frames[event.canId] != null) {
        framesBytesChange[event.canId] = event.bytes.asMap().entries.map((element) {
          return computeByteChange(event, element.key, element.value);
        }).toList();
      }
      frames[event.canId] = event;
      setState(() {});
    });
  }

  ByteChange computeByteChange(CanFrame canFrame, int byteIndex, int byteValue) {
    ByteChange? lastChange = framesBytesChange[canFrame.canId]?.elementAt(byteIndex);

    if (lastChange != null) {
      if (lastChange.value != byteValue) {
        return ByteChange(FrameByteState.CHANGED, byteValue);
      } else if (DateTime.now().millisecondsSinceEpoch - lastChange.date.millisecondsSinceEpoch >= 3000) {
        lastChange.state = FrameByteState.OLD;
      } else if (DateTime.now().millisecondsSinceEpoch - lastChange.date.millisecondsSinceEpoch >= 1500) {
        lastChange.state = FrameByteState.NORMAL;
      }

      return lastChange;
    }

    return ByteChange(FrameByteState.NORMAL, byteValue);
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

    List<Widget> allFramesRows = List.empty(growable: true);

    allFramesRows.add(new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          new SizedBox(
              width: 200,
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

    allFramesRows.addAll(framesSorted.map((entry) {
      List<Widget> allRows = List.empty(growable: true);
      List<Widget> firstRow = List.empty(growable: true);

      Dbc? dbc;

      try {
        dbc = dbcs.firstWhere((element) => element.canId == entry.key);
      } catch(e) {}

      firstRow.add(new SizedBox(
          width: 200,
          child: new Text(entry.key.toUpperCase() + (dbc != null ? '\n[' + dbc.name + ']' : '') + '\n' + (DateTime.now().millisecondsSinceEpoch - entry.value.date.millisecondsSinceEpoch).toString() + 'ms', style: TextStyle(fontWeight: FontWeight.bold),)
      ));

      firstRow.addAll(entry.value.bytesToString().asMap().entries.map((element) {
        ByteChange byteChange = computeByteChange(entry.value, element.key, entry.value.bytes[element.key]);

        ByteChange? lastChange = framesBytesChange[entry.key]?.elementAt(element.key);
        if (lastChange != null) {
          if (lastChange.state != byteChange.state) {
            framesBytesChange[entry.key]![element.key] = byteChange;
          }
        }

        return new SizedBox(
          width: 70,
          child: new Text(element.value + '\n' + (DateTime.now().millisecondsSinceEpoch - byteChange.date.millisecondsSinceEpoch).toString() + 'ms',
            style: TextStyle(
                backgroundColor: byteChange.state == FrameByteState.CHANGED ? Colors.red : Colors.white,
                color: byteChange.state == FrameByteState.CHANGED ? Colors.white : byteChange.state == FrameByteState.OLD ? Colors.grey : Colors.black
            ),
          )
      );
      }));

      firstRow.add(new SizedBox(
          width: 80,
          child: new Text(entry.value.bytesToAsciiString())
      ));

      allRows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: firstRow,
      ));

      List<Widget> secondRow = List.empty(growable: true);
      secondRow.add(new SizedBox(width: 200,));

      secondRow.addAll(entry.value.bytes16ToString().map((element) => new SizedBox(
        width: 140,
        child: new Text(element),
      )));

      allRows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: secondRow,
      ));

      if (dbc?.signals.isNotEmpty == true) {
        allRows.add(new Text(dbc!.signals.where((signal) => signal.isInterestingSignal() && signal.comment != 'byte' && signal.comment != 'long').map((signal) => signal.name + ' : ' + signal.getValueFromBitesAsString(entry.value.bits) + (signal.postfixMetric != null ? ' ' + signal.postfixMetric! : '')).join('\n'),));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: allRows
      );
    }).toList());

    return ListView(
      padding: const EdgeInsets.all(8),
      children: allFramesRows
    );
  }
}

enum FrameByteState {
  NORMAL,
  CHANGED,
  OLD
}

class ByteChange {
  final DateTime date = DateTime.now();
  FrameByteState state;
  final int value;

  ByteChange(this.state, this.value);
}