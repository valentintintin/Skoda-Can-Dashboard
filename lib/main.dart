import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/dbc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:bit_array/bit_array.dart';

import 'dbc.dart';

/*
 0x3EB : BIT 0 (checksum ?) / BIT 1 / BIT 2
 0x5E9 : BIT 5 ? 1 ?

 0x31B : BIT 2 & 3 = LONG 1
 */

List<Dbc> dbcs = List<Dbc>.empty(growable: true);
List<Dbc> dbcsTried = List<Dbc>.empty(growable: true);
var serialLog;
int serialLogIndex = 0;

Stream<CanFrame>? streamSerial;
StreamController<CanFrame> streamController = StreamController<CanFrame>.broadcast();

void main() {
  streamSerial = streamController.stream;

  final path = Directory.current.path;

  List<Dbc> dbcsRead = (jsonDecode(File('$path/vw_mqb_2010.json').readAsStringSync()) as List<dynamic>).map((e) => Dbc.fromJson(e)).toList();

  File('$path/ids.csv').readAsStringSync().split("\n").forEach((id) {
    String canId = id.padLeft(8, '0').toUpperCase();

    try {
      Dbc dbc = dbcsRead.firstWhere((dbc) => dbc.canId == canId);
      if (dbc.signals.isEmpty == true) {
        List<Signal> signals = List<Signal>.generate(8, (index) => new Signal(name: 'Byte ' + index.toString(), label: 'Byte ' + index.toString(), startBit: index * 8, bitLength: 8, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'byte', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()), growable: true);
        List<Signal> signals2 = List<Signal>.generate(4, (index) => new Signal(name: 'Long ' + index.toString(), label: 'Long ' + index.toString(), startBit: index * 16, bitLength: 16, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'long', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()));
        signals.addAll(signals2);
        dbc.signals.addAll(signals);
        dbcsTried.add(dbc);
      }
      dbcs.add(dbc);
    } catch(e)  {
      List<Signal> signals = List<Signal>.generate(8, (index) => new Signal(name: 'Byte ' + index.toString(), label: 'Byte ' + index.toString(), startBit: index * 8, bitLength: 8, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'byte', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()), growable: true);
      List<Signal> signals2 = List<Signal>.generate(4, (index) => new Signal(name: 'Long ' + index.toString(), label: 'Long ' + index.toString(), startBit: index * 16, bitLength: 16, isLittleEndian: true, isSigned: false, factor: 1, offset: 0, min: 0, max: 0, dataType: 'int', choking: false, visibility: true, interval: 0, category: 'Test', comment: 'long', lineInDbc: 0, problems: List.empty(), sourceUnit: null, postfixMetric: null, states: List.empty()));
      signals.addAll(signals2);
      dbcsTried.add(new Dbc(canId: canId, pgn: 0, name: 'Test', label: 'Test', isExtendedFrame: false, dlc: 0, comment: 'Test', signals: signals));
    }
  });

  dbcs.sort((a, b) => a.name.compareTo(b.name));
  dbcs.forEach((dbc) {
    dbc.signals.sort((a, b) => a.name.compareTo(b.name));
  });

  serialLog = File('$path/canbus.csv').readAsStringSync().split("\n").map((e) {
    try {
      return CanFrame(e.trim());
    } catch(e) {
      return null;
    }
  }).where((element) => element != null).toList();
  var serialLogCount = serialLog.length;

  Timer.periodic(new Duration(milliseconds: 1), (timer) {
    if (serialLogIndex < serialLogCount) {
      var frame = serialLog[serialLogIndex++];
      streamController.add(frame);
      //debugPrint(frame.toString());
    } else {
      serialLogIndex = 0;
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Skoda CAN Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.dashboard), text: 'Dashboard',),
                    Tab(icon: Icon(Icons.directions_car), text: 'All',),
                    Tab(icon: Icon(Icons.terrain_sharp), text: 'Try',),
                    Tab(icon: Icon(Icons.sync_alt), text: 'Raw Serial data',),
                  ],
                ),
                title: const Text('Skoda CAN Dashboard'),
              ),
              body: TabBarView(
                children: [
                  DashboardPage(onlyChoosen: true,),
                  DashboardPage(),
                  DashboardPage(onlyTry: true,),
                  RawSerialPage(),
                ],
              ),
            )
        )
    );
  }
}

class DashboardPage extends StatelessWidget {
  final bool? onlyChoosen;
  final bool? onlyTry;

  const DashboardPage({ Key? key, this.onlyChoosen, this.onlyTry }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = [];

    if (onlyTry != true && dbcs.isNotEmpty == true) {
      dbcs.forEach((dbc) {
        if (onlyChoosen != true) {
          items.add(new StringAsciiWidget(dbc: dbc));
        }

        if (dbc.signals.isNotEmpty) {
          dbc.signals.forEach((signal) {
            if (!signal.name.toLowerCase().contains('counter') && !signal.name.toLowerCase().endsWith('bz') && !signal.name.toLowerCase().contains('crc') && !signal.name.toLowerCase().contains('checksum')) {
              if (onlyChoosen != true ||
                  (
                      signal.name == 'KBI_outside_temp_gef'
                      || signal.name == 'ESP_Yaw_rate'
                      || signal.name == 'ESP_transverse_acceleration'
                      || signal.name.contains('Turn')
                      || signal.name.contains('ACC_Distance')
                      || signal.name == 'ACC_desired_speed'
                      || signal.name == 'KBI_speed'
                      || signal.name == 'KBI_Kilometre_reading'
                      || signal.name == 'KBI_Content_Tank'
                      || signal.name == 'MO_indicator_speed'
                      || signal.name == 'Ventilation_Vitesse'
                    )
                  ) {
                if (signal.states?.isNotEmpty == true) {
                  items.add(new StringWidget(dbc: dbc, signal: signal,));
                } else if (signal.bitLength == 1) {
                  items.add(new BoolWidget(dbc: dbc, signal: signal,));
                } else {
                  items.add(new GaugeWidget(dbc: dbc, signal: signal,));
                }
              }
            }
          });
        }
      });
    } else if (onlyTry == true) {
      if (dbcsTried.isNotEmpty == true) {
        dbcsTried.forEach((dbc) {
          items.add(new StringAsciiWidget(dbc: dbc));

          if (dbc.signals.isNotEmpty) {
            dbc.signals.forEach((signal) {
              items.add(new GaugeWidget(dbc: dbc, signal: signal,));
              if (signal.comment == 'byte') {
                items.add(new AsciiWidget(dbc: dbc, signal: signal,));
              }
            });
          }
        });
      }
    }

    return Center(
        child: GridView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: items.length,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5),
          itemBuilder: (BuildContext context, int index) {
            return items[index];
          }
        )
    );
  }
}

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

    return ListView(
        padding: const EdgeInsets.all(8),
        children: framesSorted.map((entry) => Text(entry.value.toString())).toList()
    );
  }
}

class BoolWidget extends StatefulWidget {
  final Dbc dbc;
  final Signal signal;

  const BoolWidget({ Key? key, required this.dbc, required this.signal })
      : super(key: key);

  @override
  _BoolWidgetState createState() => _BoolWidgetState(dbc, signal);
}

class _BoolWidgetState extends State<BoolWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final Signal signal;

  bool value = false;

  _BoolWidgetState(this.dbc, this.signal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        value = signal.getValueFromBitesAsBoolean(event.bits);
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
          Text(signal.name + ' [' + signal.name + ' [' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
          stateWidget
        ]
    );
  }
}

class StringWidget extends StatefulWidget {
  final Dbc dbc;
  final Signal signal;

  const StringWidget({ Key? key, required this.dbc, required this.signal })
      : super(key: key);

  @override
  _StringWidgetState createState() => _StringWidgetState(dbc, signal);
}

class _StringWidgetState extends State<StringWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final Signal signal;

  String value = '';

  _StringWidgetState(this.dbc, this.signal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        value = signal.getValueFromBitesAsString(event.bits);
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
          Text(signal.name + ' [' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold)),
        ]
    );
  }
}

class AsciiWidget extends StatefulWidget {
  final Dbc dbc;
  final Signal signal;

  const AsciiWidget({ Key? key, required this.dbc, required this.signal })
      : super(key: key);

  @override
  _AsciiWidgetState createState() => _AsciiWidgetState(dbc, signal);
}

class _AsciiWidgetState extends State<AsciiWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final Signal signal;

  String value = '';

  _AsciiWidgetState(this.dbc, this.signal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        if (value.length >= 40) {
          value = '';
        }

        value += signal.getValueFromBitesAsAscii(event.bits);
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
          Text(signal.name + ' ASCII [' + dbc.name + ' 0x' + dbc.canId + ']', style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.orange)),
          Text(value, style: TextStyle(
              fontSize: 17.0,fontWeight: FontWeight.bold, color: Colors.orange)),
        ]
    );
  }
}

class StringAsciiWidget extends StatefulWidget {
  final Dbc dbc;

  const StringAsciiWidget({ Key? key, required this.dbc })
      : super(key: key);

  @override
  _StringAsciiWidgetState createState() => _StringAsciiWidgetState(dbc);
}

class _StringAsciiWidgetState extends State<StringAsciiWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;

  String value = '';

  _StringAsciiWidgetState(this.dbc);

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

class GaugeWidget extends StatefulWidget {
  final Dbc dbc;
  final Signal signal;

  const GaugeWidget({ Key? key, required this.dbc, required this.signal }) : super(key: key);

  @override
  _GaugeWidgetState createState() => _GaugeWidgetState(dbc, signal);
}

class _GaugeWidgetState extends State<GaugeWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final Signal signal;

  double value = 0;

  _GaugeWidgetState(this.dbc, this.signal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        value = signal.getValueFromBites(event.bits);
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
    double min = signal.min != 0 ? signal.min : 0;
    double max = signal.max != 0 ? signal.max : pow(2, signal.bitLength) - 1;
    List<GaugeRange>? states = signal.states?.map((state) => GaugeRange(startValue: state.value.toDouble(), endValue: state.value.toDouble(), color:Colors.grey, label: state.state,)).toList();

    return SfRadialGauge(
      title:GaugeTitle(text: signal.name + ' [' + dbc.name + ' 0x' + dbc.canId + ']', textStyle: TextStyle(
        fontSize: 17.0,fontWeight: FontWeight.bold)
      ),
      backgroundColor: signal.comment == 'long' ? Colors.black38 : signal.comment == 'byte' ? Colors.cyan : Colors.white,
      axes: <RadialAxis>[
        RadialAxis(minimum: min, maximum: max,
          startAngle: 180, endAngle: 0,
          canScaleToFit: true,
          ranges: states,
          pointers: <GaugePointer>[
            NeedlePointer(value: value.toDouble(), enableAnimation: true,
                needleStartWidth: 0, needleEndWidth: 4, needleLength: 0.7,
                knobStyle: KnobStyle(knobRadius: 1, sizeUnit: GaugeSizeUnit.logicalPixel))
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(angle: 0, positionFactor: 0, widget: Text(value.toStringAsFixed(2) + (signal.postfixMetric != null ? ' ' + signal.postfixMetric! : ''), style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 15),))
          ],
        ),
    ]);
  }
}

class CanFrame {
  final String rawFrame;
  Uint8List bytes = Uint8List(8);
  BitArray bits = BitArray(8 * 8);

  String canId = '';

  CanFrame(this.rawFrame) {
    List<String> split = rawFrame.split(',');

    if (split.length >= 12) {
      canId = split[1].toUpperCase().replaceAll('0X', '').padLeft(8, '0');

      bytes = Uint8List.fromList([
        int.parse(split[6],radix: 16),
        int.parse(split[7],radix: 16),
        int.parse(split[8],radix: 16),
        int.parse(split[9],radix: 16),
        int.parse(split[10],radix: 16),
        int.parse(split[11],radix: 16),
        int.parse(split[12],radix: 16),
        int.parse(split[13],radix: 16),
      ]);

      bits = BitArray.fromUint8List(bytes);
    }
  }

  @override
  String toString() {
    return rawFrame + ' ' + bytes.toString() + ' ' + bytesToAsciiString();
  }

  String bytesToAsciiString() {
    return bytes.where((e) => e >= 32 && e <= 128).map((e) => String.fromCharCode(e)).join('');
  }
}