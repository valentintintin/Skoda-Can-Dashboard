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
import 'package:skoda_can_dashboard/widgets/dashboard/event_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/gazoil_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/gearbox_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/kilometers_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/panel_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/pedal_brake_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/pedal_throttle_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/rpm_gauge_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/speed_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/temperature_outside_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/turn_indicator_widget.dart';
import 'package:skoda_can_dashboard/widgets/dashcam_widget.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color.fromARGB(255, 0x0, 0x37, 0x50),
        child: Center(
            child: new SingleChildScrollView(
                child: new Column( // main line + footer line for ACC
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Wrap( // main line
                          children: [
                            new Column( // first column
                                children: [
                                  new Wrap(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image(image: AssetImage('assets/images/skoda.png'), width: 40, height: 40,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClockWidget(streamFrame),
                                      ),
                                    ],
                                  ),
                                  new Wrap( // Symboles
                                      alignment: WrapAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EngineRunningWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: BrakeWidget(streamFrame),
                                        )
                                      ]
                                  ),
                                  new Wrap( // ESP
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EspYawWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EspGravitWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PedalThrottleWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PedalBrakeWidget(streamFrame),
                                        ),
                                      ]
                                  ),
                                  new Wrap( // temperature
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TemperatureOutsideWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClimSpeedWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClimAcWidget(streamFrame),
                                        ),
                                      ]
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AccSpeedWidget(streamFrame),
                                  )
                                ]
                            ),
                            new Column( // Second column
                                children: [
                                  new Wrap( // ESP
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TurnIndicatorWidget(streamFrame, TurnIndicatorDirection.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GearboxWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TurnIndicatorWidget(streamFrame, TurnIndicatorDirection.right),
                                        ),
                                      ]
                                  ),
                                  new Column( // Km/h
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RpmGaugeWidget(streamFrame),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SpeedWidget(streamFrame),
                                        ),
                                      ]
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GazoilWidget(streamFrame),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: KilometersWidget(streamFrame),
                                  ),
                                ]
                            ),
                            new Column( // third column
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 256, 
                                      height: 256,
                                      child: DashcamWidget(streamDashCamImage),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PanelWidget(streamPanelImage),
                                  ),
                                ]
                            )
                          ]
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AccDistanceWidget(streamFrame),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EventWidget(streamFrame),
                      ),
                    ]
                )
            )
        )
    );
  }
}