import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/main.dart';
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
                                        child: ClockWidget(streamVehicleState),
                                      ),
                                    ],
                                  ),
                                  new Wrap( // Symboles
                                      alignment: WrapAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EngineRunningWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: BrakeWidget(streamVehicleState),
                                        )
                                      ]
                                  ),
                                  new Wrap( // ESP
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EspYawWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: EspGravitWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PedalThrottleWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PedalBrakeWidget(streamVehicleState),
                                        ),
                                      ]
                                  ),
                                  new Wrap( // temperature
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TemperatureOutsideWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClimSpeedWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClimAcWidget(streamVehicleState),
                                        ),
                                      ]
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AccSpeedWidget(streamVehicleState),
                                  )
                                ]
                            ),
                            new Column( // Second column
                                children: [
                                  new Wrap( // ESP
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TurnIndicatorWidget(streamVehicleState, TurnIndicatorDirection.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GearboxWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TurnIndicatorWidget(streamVehicleState, TurnIndicatorDirection.right),
                                        ),
                                      ]
                                  ),
                                  new Column( // Km/h
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RpmGaugeWidget(streamVehicleState),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SpeedWidget(streamVehicleState),
                                        ),
                                      ]
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GazoilWidget(streamVehicleState),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: KilometersWidget(streamVehicleState),
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
                        child: AccDistanceWidget(streamVehicleState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EventWidget(streamVehicleState),
                      ),
                    ]
                )
            )
        )
    );
  }
}