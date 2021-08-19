import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartDbcSignalVisualisationWidget extends StatefulWidget {
  final Dbc dbc;
  final DbcSignal dbcSignal;

  const ChartDbcSignalVisualisationWidget({ Key? key, required this.dbc, required this.dbcSignal }) : super(key: key);

  @override
  _ChartDbcSignalVisualisationWidgetState createState() => _ChartDbcSignalVisualisationWidgetState(dbc, dbcSignal);
}

class _ChartDbcSignalVisualisationWidgetState extends State<ChartDbcSignalVisualisationWidget> {
  StreamSubscription? serialListening;

  final Dbc dbc;
  final DbcSignal dbcSignal;

  List<_ChartData> values = List.empty(growable: true);

  _ChartDbcSignalVisualisationWidgetState(this.dbc, this.dbcSignal);

  @override
  void initState() {
    super.initState();
    serialListening = streamSerial?.listen((event) {
      if (event.canId == dbc.canId) {
        if (values.length >= 500) {
          values.clear();
        }

        values.add(new _ChartData(DateTime.now().millisecondsSinceEpoch, dbcSignal.getValueFromBites(event.bits)));
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

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: dbcSignal.name + ' [' + dbc.name + ' 0x' + dbc.canId + ']', textStyle: TextStyle(
          fontSize: 17.0,fontWeight: FontWeight.bold)
      ),
      backgroundColor: dbcSignal.comment == 'long' ? Colors.black38 : dbcSignal.comment == 'byte' ? Colors.cyan : Colors.white,
      legend: Legend(
        isVisible: false,
        overflowMode: LegendItemOverflowMode.wrap),
      primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          axisLine: const AxisLine(width: 0),
          minimum: min,
          maximum: max,
      ),
      series: [LineSeries<_ChartData, num>(
          animationDuration: 0,
          dataSource: values,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y,
          width: 1,
      )],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final int x;
  final double y;
}