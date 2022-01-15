import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:skoda_can_dashboard/connections/abstract_connection.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/utils.dart';

class FakeConnection extends Connection {
  List<CanFrame>? fakeFrames;
  Timer? timer;

  FakeConnection(StreamController<CanFrame> streamControllerCanFrame) : super(streamControllerCanFrame);

  @override
  bool isConnected() {
    return fakeFrames?.isNotEmpty ?? false;
  }

  Future<void> init(String filePath, { int timerMs = 5 }) async {
    fakeFrames = List.from(
        (await getStringFromAssets(filePath))
            .split('\n')
            .map((rawFrame) {
          if (rawFrame.length < 10 || rawFrame.startsWith('Time')) {
            return null;
          }

          try {
            return SimpleCanFrame.fromCsv(rawFrame).transformToCanFrame();
          } catch(e, stacktrace) {
            print("Fake CAN Frame error !\n" + rawFrame + "\n" + e.toString() + "\n" + stacktrace.toString());
            return null;
          }
        }).where((element) => element != null).toList()
    );

    int frameIndex = 0;
    int framesCount = fakeFrames!.length;
    
    timer = Timer.periodic(new Duration(milliseconds: timerMs), (timer) {
      try {
        CanFrame frame = fakeFrames![frameIndex++];

        int timestamp = frame.timestamp + 500;
        while (frame.timestamp < timestamp) {
          frame.dateTimeReceived = DateTime.now();

          addNewFrame(frame);

          if (frameIndex >= framesCount) {
            throw new Exception('Cycle !');
          }
          
          frame = fakeFrames![frameIndex++];
        }
      } catch (e) {
        frameIndex = 0;
      }
    });
  }

  void stop() {
    if (timer != null) {
      timer!.cancel();
    }
  }
}