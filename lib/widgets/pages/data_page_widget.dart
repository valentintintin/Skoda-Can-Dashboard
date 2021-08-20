import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/widgets/bytes_string_dbc_signal_visualisation_widget.dart';

import '../data_boolean_visualisation_widget.dart';
import '../data_chart_visualisation_widget.dart';
import '../gauge_dbc_signal_visualisation_widget.dart';
import '../string_dbc_signal_visualisation_widget.dart';

class DataPage extends StatelessWidget {
  final bool? onlyChosen;
  final bool? onlyTry;

  const DataPage({ Key? key, this.onlyChosen, this.onlyTry }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> allRows = List.empty(growable: true);

    if (onlyTry != true && dbcs.isNotEmpty == true) {
      dbcs.forEach((dbc) {
        if (onlyChosen != true) {
          allRows.add(new BytesStringDbcSignalVisualisationWidget(dbc: dbc));
        }

        if (dbc.signals.isNotEmpty) {
          dbc.signals.where((dbcSignal) => dbcSignal.isInterestingSignal()).forEach((dbcSignal) {
            List<Widget> dbcColumn = [];

            if (onlyChosen != true ||
                (
                    dbcSignal.name == 'KBI_outside_temp_gef'
                        || dbcSignal.name == 'ESP_Yaw_rate'
                        || dbcSignal.name == 'ESP_transverse_acceleration'
                        || dbcSignal.name.contains('Turn')
                        || dbcSignal.name == 'ACC_Distance_Index'
                        || dbcSignal.name == 'ACC_desired_speed'
                        || dbcSignal.name == 'KBI_speed'
                        || dbcSignal.name == 'KBI_Kilometre_reading'
                        || dbcSignal.name == 'KBI_Content_Tank'
                        || dbcSignal.name == 'MO_indicator_speed'
                        || dbcSignal.name == 'Ventilation_Vitesse'
                )
            ) {
              if (dbcSignal.states?.isNotEmpty == true) {
                dbcColumn.add(new StringDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              } else if (dbcSignal.bitLength == 1) {
                dbcColumn.add(new BooleanDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
                dbcColumn.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              } else {
                dbcColumn.add(new GaugeDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
                dbcColumn.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
                dbcColumn.add(new StringDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              }

              allRows.add(Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: dbcColumn
              ));
            }
          });
        }
      });
    } else if (onlyTry == true) {
      allRows.add(new Text('Here, I try to show every bytes (8 and 16) in different chart and ASCII to see what happens'));
      
      if (dbcsTried.isNotEmpty == true) {
        dbcsTried.forEach((dbc) {
          allRows.add(new BytesStringDbcSignalVisualisationWidget(dbc: dbc));

          if (dbc.signals.isNotEmpty) {
            dbc.signals.forEach((dbcSignal) {
              List<Widget> dbcColumn = [];

              dbcColumn.add(new GaugeDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              dbcColumn.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              dbcColumn.add(new StringDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));

              allRows.add(Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: dbcColumn
              ));
            });
          }
        });
      }
    }

    return ListView(
        padding: const EdgeInsets.all(8),
        children: allRows
    );
  }
}