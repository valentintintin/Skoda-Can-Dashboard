import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/widgets/bytes_string_dbc_signal_visualisation_widget.dart';

import '../data_boolean_visualisation_widget.dart';
import '../data_chart_visualisation_widget.dart';
import '../gauge_dbc_signal_visualisation_widget.dart';
import '../string_ascii_dbc_signal_visualisation_widget.dart';

class DataPage extends StatelessWidget {
  final bool? onlyChosen;
  final bool? onlyTry;

  const DataPage({ Key? key, this.onlyChosen, this.onlyTry }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var items = [];

    if (onlyTry != true && dbcs.isNotEmpty == true) {
      dbcs.forEach((dbc) {
        if (onlyChosen != true) {
          items.add(new BytesStringDbcSignalVisualisationWidget(dbc: dbc));
        }

        if (dbc.signals.isNotEmpty) {
          dbc.signals.where((dbcSignal) => dbcSignal.isInterestingSignal()).forEach((dbcSignal) {
            if (onlyChosen != true ||
                (
                    dbcSignal.name == 'KBI_outside_temp_gef'
                        || dbcSignal.name == 'ESP_Yaw_rate'
                        || dbcSignal.name == 'ESP_transverse_acceleration'
                        || dbcSignal.name.contains('Turn')
                        || dbcSignal.name.contains('ACC_Distance')
                        || dbcSignal.name == 'ACC_desired_speed'
                        || dbcSignal.name == 'KBI_speed'
                        || dbcSignal.name == 'KBI_Kilometre_reading'
                        || dbcSignal.name == 'KBI_Content_Tank'
                        || dbcSignal.name == 'MO_indicator_speed'
                        || dbcSignal.name == 'Ventilation_Vitesse'
                )
            ) {
              if (dbcSignal.states?.isNotEmpty == true) {
                items.add(new StringAsciiDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              } else if (dbcSignal.bitLength == 1) {
                items.add(new BooleanDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
                items.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              } else {
                items.add(new GaugeDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
                items.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              }
            }
          });
        }
      });
    } else if (onlyTry == true) {
      if (dbcsTried.isNotEmpty == true) {
        dbcsTried.forEach((dbc) {
          items.add(new BytesStringDbcSignalVisualisationWidget(dbc: dbc));

          if (dbc.signals.isNotEmpty) {
            dbc.signals.forEach((dbcSignal) {
              items.add(new GaugeDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              items.add(new ChartDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
              if (dbcSignal.comment == 'byte') {
                items.add(new StringAsciiDbcSignalVisualisationWidget(dbc: dbc, dbcSignal: dbcSignal,));
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
                crossAxisCount: 4),
            itemBuilder: (BuildContext context, int index) {
              return items[index];
            }
        )
    );
  }
}