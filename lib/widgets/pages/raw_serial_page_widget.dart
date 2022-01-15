import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RawSerialPage extends StatefulWidget {
  @override
  _RawSerialPageState createState() => _RawSerialPageState();
}

class _RawSerialPageState extends State<RawSerialPage> {
  StreamSubscription? serialListening;

  Map<int, CanFrame> frames = new Map();
  Map<int, bool> framesChartEnable = new Map();
  Map<int, List<ByteChange>> framesBytesChange = new Map();

  @override
  void initState() {
    super.initState();
    serialListening = streamFrame.asBroadcastStream().listen((event) {
      if (frames[event.canId] != null) {
        framesBytesChange[event.canId] = event.bytes.asMap().entries.map((element) {
          return computeByteChange(event, element.key, element.value);
        }).toList();
      } else {
        framesChartEnable[event.canId] = false;
      }
      
      frames[event.canId] = event;
      setState(() {});
    });
  }

  ByteChange computeByteChange(CanFrame canFrame, int byteIndex, int byteValue) {
    ByteChange? lastChange;

    try {
      lastChange = framesBytesChange[canFrame.canId]?.elementAt(byteIndex);
    } catch (e) {
      // ignored
    }

    if (lastChange != null) {
      if (lastChange.value != byteValue) {
        lastChange.change(byteValue);
      } else if (DateTime.now().millisecondsSinceEpoch - lastChange.date.millisecondsSinceEpoch >= 3000) {
        lastChange.state = FrameByteState.OLD;
      } else if (DateTime.now().millisecondsSinceEpoch - lastChange.date.millisecondsSinceEpoch >= 1500) {
        lastChange.state = FrameByteState.NORMAL;
      }

      return lastChange;
    }

    return ByteChange(byteIndex, FrameByteState.NORMAL, byteValue);
  }

  String millisecondsToStringFromNow(DateTime dateTime) {
    int milliseconds = (DateTime.now().millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch);

    if (milliseconds >= 1000) {
      double seconds = milliseconds / 1000;
      return seconds.toStringAsFixed(2) + 's';
    }

    return milliseconds.toString() + 'ms';
  }

  @override
  void dispose() {
    super.dispose();
    serialListening?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<int, CanFrame>> framesSorted = frames.entries.toList();
    framesSorted.sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      children: framesSorted.map((entry) {
        Dbc? dbc;

        try {
          dbc = dbcs.firstWhere((element) => element.canId == entry.key);
        } catch (e) {}

        entry.value.bytesToString().asMap().entries.forEach((element) {
          if (!framesBytesChange.containsKey(entry.key)) {
            framesBytesChange[entry.key] = List<ByteChange>.empty(growable: true);
          }

          ByteChange byteChange = computeByteChange(entry.value, element.key, entry.value.bytes[element.key]);

          try {
            ByteChange? lastChange = framesBytesChange[entry.key]![element.key];

            if (lastChange.state != byteChange.state) {
              framesBytesChange[entry.key]![element.key] = byteChange;
            }
          } catch(e) {
            framesBytesChange[entry.key]!.insert(element.key, byteChange);
          }
        });

        List<XyDataSeries<ChartData, num>> series = List.empty(growable: true);

        framesBytesChange[entry.key]!.forEach((e) => {
          series.add(StepLineSeries<ChartData, num>(
            animationDuration: 0,
            name: 'B' + e.index.toString(),
            dataSource: e.values,
            xValueMapper: (ChartData values, _) => values.x,
            yValueMapper: (ChartData values, _) => values.y,
            width: 1,
          ))
        });

        return Center(
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Wrap(
                    children: [
                      Column(
                          children: [
                            Text(
                              '0x' + entry.key.toRadixString(16).toUpperCase().padLeft(8, '0') + (dbc != null ? ' [' + dbc.name + ']' : '')
                                  + ' ' + millisecondsToStringFromNow(entry.value.dateTimeReceived),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Wrap(
                              children: entry.value.bytesToString().asMap().entries.map((element) {
                                return getBytesWidget(entry, element);
                              }).toList(),
                            ),
                            Wrap(
                              children: entry.value.bytes16ToString().asMap().entries.map((element) {
                                return getLongsWidget(element);
                              }).toList(),
                            ),
                            TextButton(onPressed: () => {
                              framesBytesChange[entry.key]!.forEach((e) => {
                                e.values.clear() 
                              })
                            }, child: Text('Clear chart')),
                            ToggleButtons(
                              children: <Widget>[
                                const Text('Chart'),
                              ],
                              onPressed: (int index) {
                                setState(() {
                                  framesChartEnable[entry.key] = !framesChartEnable[entry.key]!;
                                });
                              },
                              isSelected: [framesChartEnable[entry.key] ?? false],
                            ),
                            framesChartEnable[entry.key] == true ? SizedBox(
                              width: 500,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                title: ChartTitle(
                                    text: 'Bytes',
                                    textStyle: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold)
                                ),
                                legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                primaryYAxis: NumericAxis(
                                  labelFormat: '{value}',
                                  axisLine: const AxisLine(width: 0),
                                  minimum: 0,
                                  maximum: 255,
                                ),
                                series: series,
                                tooltipBehavior: TooltipBehavior(enable: true),
                              ),
                            ) : SizedBox(),
                          ]),
                      dbc?.signals.isNotEmpty == true ?
                      Text('Signals :\n\n' + dbc!.signals.where((signal) => signal.isInterestingSignal() && signal.comment != 'byte' && signal.comment != 'long').map((signal) => signal.name + ' : ' + signal.getValueFromBitesAsString(entry.value.bits) + (signal.postfixMetric != null ? ' ' + signal.postfixMetric! : '')).join('\n'),)
                          : SizedBox(),
                    ])
            )
        );
      }).toList(),
    );
  }

  Widget getBytesWidget(MapEntry<int, CanFrame> entry, MapEntry<int, String> element) {
    ByteChange byteChange = framesBytesChange[entry.key]![element.key];

    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            children: [
              Text(
                'B' + element.key.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                element.value
                    + '\n' + millisecondsToStringFromNow(byteChange.date),
                style: TextStyle(
                    backgroundColor: byteChange.state == FrameByteState.CHANGED ? Colors.red : Colors.transparent,
                    color: byteChange.state == FrameByteState.CHANGED ? Colors.white : byteChange.state == FrameByteState.OLD ? Colors.grey : Colors.black
                ),
              )
            ]
        )
    );
  }

  Widget getLongsWidget(MapEntry<int, String> element) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            children: [
              Text(
                'L' + element.key.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(element.value)
            ]
        )
    );
  }
}

enum FrameByteState {
  NORMAL,
  CHANGED,
  OLD
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final int y;
}

class ByteChange {
  final index;
  DateTime date = DateTime.now();
  FrameByteState state;
  int value;
  List<ChartData> values = List.empty(growable: true);

  ByteChange(this.index, this.state, this.value) {
    values.add(ChartData(date.millisecondsSinceEpoch, value));
  }

  void change(int newValue) {
    date = DateTime.now();
    value = newValue;
    state = FrameByteState.CHANGED;

    if (values.length >= 300) {
      values.clear();
    }

    values.add(ChartData(date.millisecondsSinceEpoch, value));
  }
}