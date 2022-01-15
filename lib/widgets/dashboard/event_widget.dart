
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/acc_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climate_11_frame.dart';
import 'package:skoda_can_dashboard/model/frames/climatronic_frame.dart';
import 'package:skoda_can_dashboard/model/frames/combi_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';
import 'package:skoda_can_dashboard/model/frames/esp_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/gateway_72_frame.dart';
import 'package:skoda_can_dashboard/model/frames/motor_14_frame.dart';
import 'package:skoda_can_dashboard/model/frames/station_wagon_02_frame.dart';
import 'package:skoda_can_dashboard/model/frames/wba_03_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

class EventWidget extends AbstractDashboardWidget {
  EventWidget(streamCanFrame) : super([Esp02Frame, Acc02Frame, Climate11Frame, ClimatronicFrame, Gateway72Frame, Diagnosis01Frame, StationWagon02Frame, Wba03Frame, Motor14Frame, Combi01Frame], streamCanFrame);

  @override
  State<StatefulWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends AbstractDashboardWidgetState<EventWidget> {
  final DateFormat dateFormatter = DateFormat('Hms');
  
  Queue<String> events = new Queue();

  bool valueBrake = false;
  bool valueHandBrake = true;
  bool valueEngine = false;
  String valueGearbox = '';
  int valueContentTank = 0;
  int valueKilometer = 0;
  double valueTemperatureOutside = 0;
  bool valueClimAc = false;
  int valueClimSpeed = 0;
  bool valueAccEnabled = false;
  int valueAccSpeed = 0;
  int valueSpeed = 0;
  double valueTransverseAcceleration = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 550,
        height: 200,
        child: ListView(
            children: events.map((event) => Text(
              event,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white
              ),
            )).toList()
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    bool shouldRefresh = false;

    bool newValueBrake = valueBrake;
    bool newValueHandBrake = valueHandBrake;
    bool newValueEngine = valueEngine;
    String newValueGearbox = valueGearbox;
    int newValueContentTank = valueContentTank;
    int newValueKilometer = valueKilometer;
    double newTemperatureOutside = valueTemperatureOutside;
    bool newValueClimAc = valueClimAc;
    int newValueClimSpeed = valueClimSpeed;
    bool newValueAccEnabled = valueAccEnabled;
    int newValueAccSpeed = valueAccSpeed;
    int newValueSpeed = valueSpeed;
    double newValueTransverseAcceleration = valueTransverseAcceleration;

    if (frame is Motor14Frame) {
      newValueBrake = frame.isBraking();
      newValueEngine = frame.isEngineRunning();
    } else if (frame is Combi01Frame) {
      newValueHandBrake = frame.isHandbrakeEngaged();
      newValueSpeed = frame.speed();
    } else if (frame is Wba03Frame) {
      newValueGearbox = frame.gearMode();
    } else if (frame is StationWagon02Frame) {
      newValueContentTank = frame.contentTank();
      newValueKilometer = frame.kilometer();
    } else if (frame is Diagnosis01Frame) {
      newValueKilometer = frame.kilometer();
    } else if (frame is Gateway72Frame) {
      newTemperatureOutside = frame.temperatureOutside();
    } else if (frame is ClimatronicFrame) {
      newValueClimSpeed = frame.speed();
    } else if (frame is Climate11Frame) {
      newValueClimAc = frame.isAcActivated();
    } else if (frame is Acc02Frame) {
      newValueAccEnabled = frame.isSpeedEnabled();
      newValueAccSpeed = frame.desiredSpeed();
    } else if (frame is Esp02Frame) {
      newValueTransverseAcceleration = frame.transverseAcceleration().abs();
    }

    if (newValueBrake != valueBrake) {
      valueBrake = newValueBrake;
      if (valueBrake) {
        events.addFirst(getTime() + 'Pédale de frein ' + boolToFrench(valueBrake, feminal: true));
        shouldRefresh = true;
      }
    }

    if (newValueHandBrake != valueHandBrake) {
      valueHandBrake = newValueHandBrake;
      events.addFirst(getTime() + 'Frein à main ' + boolToFrench(valueHandBrake));
      shouldRefresh = true;
    }

    if (newValueEngine != valueEngine) {
      valueEngine = newValueEngine;
      events.addFirst(getTime() + 'Moteur ' + boolToFrench(valueEngine));
      shouldRefresh = true;
    }

    if (newValueGearbox != valueGearbox) {
      valueGearbox = newValueGearbox;
      events.addFirst(getTime() + 'Levier de vitesse changé à ' + valueGearbox);
      shouldRefresh = true;
    }

    if (newValueContentTank != valueContentTank) {
      valueContentTank = newValueContentTank;
      events.addFirst(getTime() + 'Niveau d\'essence à ' + valueContentTank.toString() + ' L');
      shouldRefresh = true;
    }

    if (newValueKilometer > valueKilometer) {
      valueKilometer = newValueKilometer;
      events.addFirst(getTime() + 'Nouveau kilométrage : ' + valueKilometer.toString() + ' Km');
      shouldRefresh = true;
    }

    if (newValueClimSpeed != valueClimSpeed) {
      valueClimSpeed = newValueClimSpeed;
      events.addFirst(getTime() + 'Changement vitesse ventilation : ' + valueClimSpeed.toString());
      shouldRefresh = true;
    }

    if (newTemperatureOutside != valueTemperatureOutside) {
      bool shoudAlert = (newTemperatureOutside - valueTemperatureOutside).abs() > 2;
      valueTemperatureOutside = newTemperatureOutside;
      if (shoudAlert) {
        events.addFirst(getTime() + 'Changement température extérieure : ' + valueTemperatureOutside.toStringAsFixed(1) + ' °C');
        shouldRefresh = true;
      }
    }

    if (newValueClimAc != valueClimAc) {
      valueClimAc = newValueClimAc;
      events.addFirst(getTime() + 'Climatisation ' + boolToFrench(valueClimAc, feminal: true));
      shouldRefresh = true;
    }

    if (newValueAccEnabled != valueAccEnabled) {
      valueAccEnabled = newValueAccEnabled;
      events.addFirst(getTime() + 'Régulateur ' + boolToFrench(valueAccEnabled));
      shouldRefresh = true;
    }

    if (newValueAccSpeed != valueAccSpeed) {
      valueAccSpeed = newValueAccSpeed;
      if (valueAccSpeed >= 30) {
        events.addFirst(getTime() + 'Régulateur réglé à ' + valueAccSpeed.toString() + ' Km/h');
        shouldRefresh = true;
      }
    }

    if (newValueSpeed != valueSpeed) {
      bool shouldAlert = newValueSpeed > 135 && valueSpeed <= 135;
      valueSpeed = newValueSpeed;
      if (shouldAlert) {
        events.addFirst(getTime() + 'Dépassement de vitesse à ' + valueSpeed.toString() + ' Km/h !');
        shouldRefresh = true;
      }
    }

    if (newValueTransverseAcceleration != valueTransverseAcceleration) {
      // https://copradar.com/chapts/references/acceleration.html
      bool shouldAlert = newValueTransverseAcceleration >= 0.55 && valueTransverseAcceleration < 0.55;
      valueTransverseAcceleration = newValueTransverseAcceleration;
      if (shouldAlert) {
        events.addFirst(getTime() + 'Freinage brutal !');
        shouldRefresh = true;
      }
    }

    if (shouldRefresh) {
      setState(() {});
    }

    while (events.length > 100) {
      events.removeLast();
    }
  }

  String boolToFrench(bool value, { bool feminal = false }) {
    return (value ? 'activé' : 'désactivé') + (feminal ? 'e' : '');
  }

  String getTime() {
    return dateFormatter.format(DateTime.now()) + ' - ';
  }
}
