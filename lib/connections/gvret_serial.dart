import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:skoda_can_dashboard/connections/abstract_gvret.dart';

class GvretSerial extends Gvret {
  SerialPort? port;

  GvretSerial(streamControllerFrame) : super(streamControllerFrame);
  
  void init(List<String> portsToUse) {
    if (port != null) {
      port!.close();
      port!.dispose();
      port = null;
    }

    if (SerialPort.availablePorts.isEmpty) {
      throw Exception('No serial port');
    }

    for (String portPath in portsToUse) {
      print('Test serial port : ' + portPath);
      try {
        port = SerialPort(portPath);
        if (port!.openReadWrite()) {
          print(portPath + ' OK');
          break;
        }
      } catch (e) {
        print(portPath + ' ' + e.toString());
        port = null;
      }
    }

    if (port == null) {
      throw Exception(SerialPort.lastError!.message);
    }

    var config = port!.config;
    config.baudRate = 1000000;
    port!.config = config;
    
    onConnectionSucceded();

    final reader = SerialPortReader(port!);

    reader.stream.listen((data) {
      data.forEach((c) { 
        onReceiveValue(c);
      });
    }, onError: (e) {
      print('Serial diconnected : ' + e.toString());
      port = null;
    });
  }

  @override
  void writeValues(Uint8List data) {
    port!.write(data);
  }

  @override
  bool isConnected() {
    return port != null;
  }
}