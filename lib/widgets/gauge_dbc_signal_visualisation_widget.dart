import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const GaugeDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal }) : super(key: key);

  @override
  _GaugeDbcSignalVisualisationWidgetState createState() => _GaugeDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _GaugeDbcSignalVisualisationWidgetState extends State<GaugeDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  double value = 0;

  _GaugeDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        value = dbcSignal.getValueFromBites(event.bits);
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
    double min = dbcSignal.min != 0 ? dbcSignal.min : 0;
    double max = dbcSignal.max != 0 ? dbcSignal.max : pow(2, dbcSignal.bitLength) - 1;
    List<GaugeRange>? states = dbcSignal.states?.map((state) => GaugeRange(startValue: state.value.toDouble(), endValue: state.value.toDouble(), color:Colors.grey, label: state.state,)).toList();

    return SfRadialGauge(
        title:GaugeTitle(text: dbcSignal.name + '\n[' + dbc.name + ' 0x' + dbc.canId + ']', textStyle: TextStyle(
            fontSize: 17.0,fontWeight: FontWeight.bold)
        ),
        backgroundColor: dbcSignal.comment == 'long' ? Colors.black38 : dbcSignal.comment == 'byte' ? Colors.cyan : Colors.white,
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
              GaugeAnnotation(angle: 0, positionFactor: 0, widget: Text(value.toStringAsFixed(2) + (dbcSignal.postfixMetric != null ? ' ' + dbcSignal.postfixMetric! : ''), style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),))
            ],
          ),
        ]);
  }
}