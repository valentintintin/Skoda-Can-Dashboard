import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/widgets/pages/data_page_widget.dart';
import 'package:skoda_can_dashboard/widgets/pages/raw_serial_page_widget.dart';

import 'model/can_frame.dart';
import 'model/dbc.dart';
import 'model/dbc_signal.dart';

/*
 0x3EB : BIT 0 (checksum ?) / BIT 1 / BIT 2
 0x5E9 : BIT 5 ? 1 ?
 0x3DC : BIT 3 ? LONG 1 ?
 0x31B : BIT 2 & 3 = LONG 1
 0x3DA : BIT 4 ?
 0x3EA : BIT 5 ? BIT 6 ? LONG 2 ?
 */

List<Dbc> dbcs = List<Dbc>.empty(growable: true);
List<Dbc> dbcsTried = List<Dbc>.empty(growable: true);
var serialLog;
int serialLogIndex = 0;

Stream<CanFrame>? streamSerial;
StreamController<CanFrame> streamController = StreamController<CanFrame>.broadcast();

Future<void> main() async {
  streamSerial = streamController.stream;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Future<String> getStringFromBytes(String assetKey) async {
    ByteData data = await rootBundle.load(assetKey);
    final buffer = data.buffer;
    var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return utf8.decode(list);
  }

  Future<void> computeFiles() async {
    List<Dbc> dbcsRead = (jsonDecode(await getStringFromBytes('assets/vw_mqb_2010.json')) as List<dynamic>).map((e) => Dbc.fromJson(e)).toList();

    (await getStringFromBytes('assets/ids.csv')).split("\n").forEach((id) {
      String canId = id.padLeft(8, '0').toUpperCase();

      try {
        Dbc dbc = dbcsRead.firstWhere((dbc) => dbc.canId == canId);
        if (dbc.signals.isEmpty == true) {
          List<DbcSignal> signals = List<DbcSignal>.generate(8, (index) => new DbcSignal(name: 'Byte ' + index.toString(), label: 'Byte ' + index.toString(), startBit: index * 8, bitLength: 8, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'byte', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()), growable: true);
          List<DbcSignal> signals2 = List<DbcSignal>.generate(4, (index) => new DbcSignal(name: 'Long ' + index.toString(), label: 'Long ' + index.toString(), startBit: index * 16, bitLength: 16, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'long', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()));
          signals.addAll(signals2);
          dbc.signals.addAll(signals);
          dbcsTried.add(dbc);
        }
        dbcs.add(dbc);
      } catch(e)  {
        List<DbcSignal> signals = List<DbcSignal>.generate(8, (index) => new DbcSignal(name: 'Byte ' + index.toString(), label: 'Byte ' + index.toString(), startBit: index * 8, bitLength: 8, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'byte', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()), growable: true);
        List<DbcSignal> signals2 = List<DbcSignal>.generate(4, (index) => new DbcSignal(name: 'Long ' + index.toString(), label: 'Long ' + index.toString(), startBit: index * 16, bitLength: 16, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'long', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()));
        signals.addAll(signals2);
        dbcsTried.add(new Dbc(canId: canId, pgn: 0, name: 'Test', label: 'Test', isExtendedFrame: false, dlc: 0, comment: 'Test', signals: signals));
      }
    });

    dbcs.sort((a, b) => a.name.compareTo(b.name));
    dbcs.forEach((dbc) {
      dbc.signals.sort((a, b) => a.name.compareTo(b.name));
    });

    serialLog = (await getStringFromBytes('assets/canbus.csv')).split("\n").map((e) {
      try {
        return CanFrame(e.trim());
      } catch(e) {
        return null;
      }
    }).where((element) => element != null).toList();
    int serialLogCount = serialLog.length;

    Timer.periodic(new Duration(milliseconds: 1), (timer) {
      if (serialLogIndex < serialLogCount) {
        CanFrame frame = serialLog[serialLogIndex++];
        frame.date = DateTime.now();
        streamController.add(frame);
        //debugPrint(frame.toString());
      } else {
        serialLogIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    computeFiles();

    return MaterialApp(
        title: 'Skoda CAN Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.help, size: 17,), text: 'Help',),
                    Tab(icon: Icon(Icons.dashboard, size: 17,), text: 'Future Dashboard',),
                    Tab(icon: Icon(Icons.directions_car, size: 17,), text: 'All DBC',),
                    Tab(icon: Icon(Icons.terrain_sharp, size: 17,), text: 'Not in DBC',),
                    Tab(icon: Icon(Icons.sync_alt, size: 17,), text: 'Raw Serial sniffing data',),
                  ],
                ),
                title: const Text('Skoda CAN Dashboard'),
              ),
              body: TabBarView(
                children: [
                  Center(
                    child: Text('For the moment, this app is not connected to any car.\nThere is only one dump of few seconds played in loop to analyse it !', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                  ),
                  DataPage(onlyChosen: true,),
                  DataPage(),
                  DataPage(onlyTry: true,),
                  RawSerialPage(),
                ],
              ),
            )
        )
    );
  }
}