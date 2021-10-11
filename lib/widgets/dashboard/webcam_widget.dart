import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/frames/esp_02_frame.dart';
import 'package:skoda_can_dashboard/widgets/dashboard/abstract_dashboard_widget.dart';

import '../utils.dart';

class WebcamWidget extends AbstractDashboardWidget {
  bool useFake = false;

  WebcamWidget(streamCanFrame, { bool useFake = false }) : super([Esp02Frame], streamCanFrame) {
    this.useFake = useFake;
  }

  @override
  State<StatefulWidget> createState() {
    return _WebcamWidgetState();
  }
}

class _WebcamWidgetState extends AbstractDashboardWidgetState<WebcamWidget> {
  bool isRecording = false;
  bool isTaking = false;
  late Timer timer;
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();

    takePhoto();

    timer = Timer.periodic(new Duration(milliseconds: 1200), (timer) async {
      await takePhoto();
    });
  }

  Future<void> takePhoto() async {
    if (widget.useFake || isTaking || isRecording) {
      return;
    }

    isTaking = true;

    try {
      await Process.run(
          'raspistill', [
        '--width',
        '228',
        '--height',
        '128',
        '--exposure',
        'auto',
        '--rotation',
        '90',
        '--nopreview',
        '--awb',
        'auto',
        '-st',
        '-t',
        '1000',
        '--encoding',
        'jpg',
        '--output',
        '-'
      ], stdoutEncoding: null).then((value) async =>
      {
        if (value.stdout != null) {
          await File(getNewFileName('image')).writeAsBytes(value.stdout),

          setState(() {
            imageData = value.stdout;
          })
        } else
          if (value.stderr != null) {
            print('Error raspistill : ' + value.stderr)
          },
      });

      isTaking = false;
    } catch (e, stacktrace) {
      print('Error before raspistill : ' + e.toString() + ' ' +
          stacktrace.toString());

      isTaking = false;
    }
  }

  Future<void> recordVideo() async {
    if (isRecording || isTaking) {
      return;
    }

    setState(() {
      isRecording = true;
    });

    if (widget.useFake) {
      Timer(new Duration(seconds: 30), () {
        setState(() {
          isRecording = false;
        });
      });
    } else {
      try {
        await Process.run(
            'raspivid', [
          '--width',
          '1920',
          '--height',
          '1080',
          '--exposure',
          'auto',
          '--rotation',
          '90',
          '--nopreview',
          '--awb',
          'auto',
          '-t',
          '30000',
          '-fps',
          '30',
          '--output',
          getNewFileName('video') + '.h264'
        ], stdoutEncoding: null).then((value) =>
        {
          if (value.stderr != null) {
            print('Error raspistill : ' + value.stderr)
          },

          setState(() {
            isRecording = false;
          })
        });
      } catch (e, stacktrace) {
        print('Error before raspistill : ' + e.toString() + ' ' +
            stacktrace.toString());

        setState(() {
          isRecording = false;
        });
      }
    }

    await takePhoto();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 228,
        height: 128,
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
                color: isRecording ? Colors.red : Colors.black12,
                child: IconButton(
                  icon: imageData != null ? Image(image: Image.memory(imageData!).image,) : Icon(Icons.photo_camera, color: Colors.blueGrey,),
                  onPressed: () async {
                    await recordVideo();
                  },
                )
            )
        )
    );
  }

  @override
  void onNewValue(CanFrame frame) {
    // 0.37 G/s = 8.1 m/s : https://copradar.com/chapts/references/acceleration.html
    if ((frame as Esp02Frame).transverseAcceleration() >= 0.37) {
      recordVideo();
    }
  }
}
