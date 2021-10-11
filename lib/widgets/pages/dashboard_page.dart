
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
import 'package:skoda_can_dashboard/model/frames/blinkmodi_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/acc_distance_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/acc_speed_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/brake_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/clim_ac_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/clim_speed_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/clock_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/engine_running_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/esp_gravit_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/esp_yaw_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/gazoil_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/gearbox_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/handbrake_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/kilometers_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/rpm_gauge_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/speed_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/temperature_outside_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/turn_indicator_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/webcam_widget.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(255, 0x0, 0x37, 0x50),
        child: new Column( // main line + footer line for ACC
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
              new Row( // main line
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Column( // first column
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget> [
                          Container(), // unknown for now
                          new Row( // Symbol
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: HandbrakeWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: EngineRunningWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: BrakeWidget(streamSerial),
                                )
                              ]
                          ),
                          new Row( // ESP
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: EspYawWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: EspGravitWidget(streamSerial),
                                ),
                              ]
                          ),
                          new Row( // temperature
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TemperatureOutsideWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClimSpeedWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClimAcWidget(streamSerial),
                                ),
                              ]
                          ),
                        ]
                    ),
                    new Column( // Second column
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget> [
                          new Row( // ESP
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TurnIndicatorWidget(streamSerial, TurnIndicatorDirection.left),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GearboxWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TurnIndicatorWidget(streamSerial, TurnIndicatorDirection.right),
                                ),
                              ]
                          ),
                          new Column( // ESP
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RpmGaugeWidget(streamSerial),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SpeedWidget(streamSerial),
                                ),
                              ]
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GazoilWidget(streamSerial),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: KilometersWidget(streamSerial),
                          )
                        ]
                    ),
                    new Column( // third column
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget> [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClockWidget(streamSerial),
                          ),
                          Platform.isLinux ? WebcamWidget(streamSerial, useFake: !useWebcam,) : Container(),
                        ]
                    )
                  ]
              ),
              new Row( // footer line for ACC
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AccDistanceWidget(streamSerial),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AccSpeedWidget(streamSerial),
                    ),
                  ]
              )
            ]
        )
    );
  }
}

// TextButton.icon(onPressed: () => exit(0), icon: Icon(Icons.exit_to_app, size: 30.0,), label: Text('Exit', style: TextStyle(fontSize: 30.0)))