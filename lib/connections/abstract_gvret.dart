import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:skoda_can_dashboard/connections/abstract_connection.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/utils.dart';

abstract class Gvret extends Connection {
  int rxStep = 0;
  GvretRxCommand rxState = GvretRxCommand.idle;
  final SimpleCanFrame canFrame = SimpleCanFrame();
  File? fileSave = null;
  List<int> lastData = List.empty(growable: true);

  Gvret(streamControllerCanFrame) : super(streamControllerCanFrame) {
    Timer.periodic(new Duration(seconds: 7), (timer) {
      if (isConnected()) {
        writeValues(Uint8List.fromList([0xE7, 0xF1, 0x09]));
      }
    });
  }
  
  Future<void> enableSaveData() async {
    String filePathFrames = await getNewFileName('arduino') + '.bin';
    print('Save arduino to : ' + filePathFrames);
    fileSave = File(filePathFrames);
  }
  
  void onConnectionSucceded() {
    writeValues(Uint8List.fromList([0xE7, 0xF1, 0x09]));
  }
  
  void writeValues(Uint8List data);

  /*
    Binary:
    Byte 0 - 0xF1
    Byte 1 - 00
    Byte 2-5 - Time stamp in microseconds LSB to MSB
    Byte 6-9 - Frame ID, Bit 31 - Extended Frame
    Byte 10 - Frame length in bottom 4 bits, Bus received on in upper 4 bits
    Byte 11-? - Data bytes
    Byte ?+1 - 0
   */
  void onReceiveValue(int dataReceived) {
    // print('State ' + rxState.toString() + ', Step ' + rxStep.toString() + ', received ' + dataReceived.toRadixString(16) + ', frame ' + canFrame.toString());
    
    if (fileSave != null && lastData.length >= 8) {
      fileSave!.writeAsBytesSync(lastData, mode: FileMode.writeOnlyAppend);
      lastData.clear();
    }
    
    lastData.add(dataReceived);
    
    switch (rxState) {
      case GvretRxCommand.idle:
        rxStep = 0;
        canFrame.reset();
        
        if (dataReceived == 0xF1) {
          rxState = GvretRxCommand.get_command;
        }
        break;
      case GvretRxCommand.get_command:
        rxStep = 0;
        canFrame.reset();
        
        switch (dataReceived) {
          case 0: //receiving a can frame
            rxState = GvretRxCommand.build_can_frame;
            break;
          case 9: //receiving validation (alive)
            rxState = GvretRxCommand.idle;
            break;
          default:
            print('Command not recognized');
            rxState = GvretRxCommand.idle;
            break;
        }
        break;
      case GvretRxCommand.build_can_frame:
        switch (rxStep) {
          case 0:
            canFrame.timestamp = dataReceived;
            rxStep++;
            break;
          case 1:
            canFrame.timestamp |= dataReceived << 8;
            rxStep++;
            break;
          case 2:
            canFrame.timestamp |= dataReceived << 16;
            rxStep++;
            break;
          case 3:
            canFrame.timestamp |= dataReceived << 24;
            rxStep++;
            break;
          case 4:
            canFrame.canId = dataReceived;
            rxStep++;
            break;
          case 5:
            canFrame.canId |= dataReceived << 8;
            rxStep++;
            break;
          case 6:
            canFrame.canId |= dataReceived << 16;
            rxStep++;
            break;
          case 7:
            canFrame.canId |= dataReceived << 24;
            if ((canFrame.canId & 1 << 31) == 1 << 31)
            {
              canFrame.canId &= 0x7FFFFFFF;
              canFrame.extended = true;
            }
            else {
              canFrame.extended = false;
            }
            rxStep++;
            break;
          case 8:
            canFrame.length = dataReceived & 0xF;
            
            if (canFrame.length > 8) {
              print('Too much data for a canFrame (' + canFrame.length.toString() + ') > 8');

              rxState = GvretRxCommand.idle;
              rxStep = 0;
              canFrame.reset();
              
              break;
            }
            
            canFrame.bus = (dataReceived & 0xF0) >> 4;
            rxStep++;
            break;
          default:
            if (rxStep < canFrame.bytes.length + 9) {
              canFrame.bytes[rxStep - 9] = dataReceived;
              rxStep++;
            } else {
              rxState = GvretRxCommand.idle;
              rxStep = 0;
              addNewFrame(canFrame.transformToCanFrame());
              canFrame.reset();
            }
            break;
        }
        break;
      default:
        rxState = GvretRxCommand.idle;
        rxStep = 0;
        canFrame.reset();
        print('State not recognized');
        break;
    }
  }
}

enum GvretRxCommand {
  idle,
  get_command,
  build_can_frame,
}