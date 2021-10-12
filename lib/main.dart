import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';
import 'package:skoda_can_dashboard/model/exceptions/frame_exception.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';
import 'package:skoda_can_dashboard/widgets/pages/dashboard_page.dart';
import 'package:skoda_can_dashboard/widgets/pages/raw_serial_page_widget.dart';
import 'package:skoda_can_dashboard/widgets/utils.dart';

/*
 0x3EB : BIT 0 (checksum ?) / BIT 1 / BIT 2
 0x5E9 : BIT 5 ? 1 ?
 0x3DC : BIT 3 ? LONG 1 ?
 0x31B : BIT 2 & 3 = LONG 1
 0x3DA : BIT 4 ?
 0x3EA : BIT 5 ? BIT 6 ? LONG 2 ?
 */

bool useFake = dotenv.get('useFake') == 'true';
bool useFilter = dotenv.get('useFilter') == 'true';
bool saveFrames = dotenv.get('saveFrames') == 'true';
bool useWebcam = dotenv.get('useWebcam') == 'true';
bool setDateTime = dotenv.get('setDateTime') == 'true';
String? fakeFile = dotenv.get('fakeFile');
List<String> serialPorts = dotenv.get('useSerialPort') == 'true' ? dotenv.get('serialPortDevices').split(',') : List.empty();
String? ipServer = dotenv.get('useSocket') == 'true' ? dotenv.get('ipServer') : null;
int? portServer = dotenv.get('useSocket') == 'true' ? int.parse(dotenv.get('portServer')) : null;

List<Dbc> dbcs = List<Dbc>.empty(growable: true);
List<Dbc> dbcsTried = List<Dbc>.empty(growable: true);
List<CanFrame?>? serialLog;
int serialLogIndex = 0;

SerialPort? port;
Socket? socket;

late Stream<CanFrame> streamSerial;
StreamController<CanFrame> streamController = StreamController<CanFrame>.broadcast();

void initSerialPort() {
  if (port != null) {
    port!.close();
  }

  if (SerialPort.availablePorts.isEmpty) {
    throw Exception('No serial port');
  }

  for (String portPath in serialPorts) {
    // print('Test serial port : ' + portPath);
    port = SerialPort(portPath);
    if (port!.openReadWrite()) {
      // print(portPath + ' OK');
      break;
    }
    // print(SerialPort.lastError!.message);
    port = null;
  }

  if (port == null) {
    throw Exception(SerialPort.lastError!.message);
  }

  var config = port!.config;
  config.baudRate = 1000000;
  port!.config = config;

  port!.write(Uint8List.fromList([0xE7, 0xF1, 0x09]));

  final reader = SerialPortReader(port!);

  reader.stream.listen((data) {
    if (data[0] != 0xF1 || data[1] != 0) {
      return;
    }

    try {
      transformBytesToCanFrame(data);
    } catch (e) {
      // ignored
    }
  }, onError: (e) {
    // print('Serial diconnected : ' + e.toString());
    port = null;
  });
}

Future<void> initSocket() async {
  if (socket != null) {
    socket!.close();
  }

  // print('Try socket');

  // fixme throw exception, how to catch ?
  socket = await Socket.connect(ipServer!, portServer!, timeout: Duration(seconds: 4));

  try {
    await socket!.done;
  }
  catch(e) {}
  
  socket!.add(Uint8List.fromList([0xE7, 0xF1, 0x09]));

  List<int> buffer = List<int>.empty(growable: true);

  socket!.listen((data) {
    buffer.addAll(data);

    if (buffer[0] != 0xF1 || buffer[1] != 0) {
      buffer.clear();
      return;
    }

    try {
      transformBytesToCanFrame(Uint8List.fromList(buffer));
      buffer.clear();
    } on CanFrameCsvWrongException  {
      buffer.clear();
    }  on FrameWrongException {
      buffer.clear();
    } catch (e) {
      if (buffer.length > 12288) {
        buffer.clear();
      }
    }
  }, onError: (e) {
    // print('Socket diconnected : ' + e.toString());
    socket = null;
  });
}

CanFrame transformBytesToCanFrame(Uint8List data) {
  try {
    CanFrame frame = CanFrame.make(data);
    streamController.add(frame);
    return frame;
  } catch(e, stacktrace) {
    print("CAN Frame error !\n" + e.toString() + "\n" + stacktrace.toString());
    throw e;
  }
}

void tryConnect() {
  // print('Try connect');

  if (serialPorts.isNotEmpty) {
    try {
      initSerialPort();
      return;
    } catch (e) {
      // print('Serial port error : ' + e.toString());    
    }
  }
  
  if (ipServer != null && portServer != null) {
    try {
      initSocket();
    } catch (e) {
      // print('Telnet error : ' + e.toString());
    }
  }
}

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  
  streamSerial = streamController.stream;

  if (saveFrames) {
    File fileSave = File(getNewFileName('canbus') + '.csv');

    streamSerial.listen((event) {
      fileSave.writeAsStringSync(event.toCsv(), mode: FileMode.writeOnlyAppend);
    });
  }
  
  if (setDateTime) {
    streamSerial.listen((event) async {
      if (event is Diagnosis01Frame) {
        if ((DateTime.now().millisecondsSinceEpoch - event.dateTime().millisecondsSinceEpoch).abs() >= 2 * 60 * 1000) {
          /*
          visudo
          pi ALL=(ALL) NOPASSWD: /usr/bin/date
           */
          await Process.run('date', [
            '+"%Y-%m-%dT%H:%M:%S"',
            '-s',
            event.dateTime().toIso8601String()
          ]);
        }
      }
    });
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(FutureBuilder(
    future: computeFiles(),
    builder: (_, snap) {
      if (snap.hasError) {
        throw Exception(snap.error.toString() + ' : ' + snap.stackTrace.toString());
      }
      if(snap.hasData) {
        Timer.periodic(new Duration(seconds: 5), (timer) {
          if (socket != null) {
            useFake = false;
            socket!.add(Uint8List.fromList([0xE7, 0xF1, 0x09]));
          } else if (port != null) {
            useFake = false;
            port!.write(Uint8List.fromList([0xE7, 0xF1, 0x09]));
          } else {
            tryConnect();
          }
        });

        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int nbFrames = 0;
  int framesPerSeconds = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        framesPerSeconds = nbFrames;
      });
      nbFrames = 0;
    });

    streamSerial.asBroadcastStream().listen((frame) {
      nbFrames++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Image imageSkoda = Image(image: AssetImage('assets/images/skoda.png'),);

    IconData connectionStateIcon;
    if (port != null) {
      connectionStateIcon = Icons.usb;
    } else if (socket != null) {
      connectionStateIcon = Icons.network_wifi;
    } else if (serialLog?.isNotEmpty == true) {
      connectionStateIcon = Icons.pattern;
    } else {
      connectionStateIcon = Icons.mobiledata_off;
    }

    return MaterialApp(
        title: 'Skoda CAN Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                leading: Padding(
                    padding: EdgeInsets.all(8),
                    child: imageSkoda
                ),
                title: Text('Skoda CAN Dashboard'),
                actions: <Widget>[
                  Icon(connectionStateIcon),
                  framesPerSeconds > 0 ? TextButton.icon(onPressed: () {}, icon: Icon(Icons.stream), label: Text(framesPerSeconds.toString() + ' FPS', style: TextStyle(color: Colors.white),)) : Container(),
                  Padding(
                      padding: EdgeInsets.only(left: 24, right: 24),
                      child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                if (Platform.isAndroid) {
                                  SystemNavigator.pop();
                                } else {
                                  exit(0);
                                }
                              },
                            )
                          ]
                      )
                  )
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.directions_car)),
                    // Tab(icon: Icon(Icons.directions_car, size: 17,), text: 'All DBC',),
                    // Tab(icon: Icon(Icons.dashboard, size: 17,), text: 'Not in DBC',),
                    Tab(icon: Icon(Icons.find_in_page,)),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  DashboardPage(),
                  // DataPage(),
                  // DataPage(onlyTry: true,),
                  RawSerialPage(),
                ],
              ),
            )
        )
    );
  }
}

Future<String> getStringFromAssets(String assetKey) async {
  return await rootBundle.loadString(assetKey);
}

Future<bool> computeFiles() async {
  List<Dbc> dbcsRead = (jsonDecode(await getStringFromAssets('assets/vw_mqb_2010.json')) as List<dynamic>).map((e) => Dbc.fromJson(e)).toList();

  if (useFilter) {
    (await getStringFromAssets('assets/ids.csv')).split("\n").forEach((id) {
      int canId = int.parse(id, radix: 16);

      try {
        Dbc dbc = dbcsRead.firstWhere((dbc) => dbc.canId == canId);
        if (dbc.signals.isEmpty == true) {
          List<DbcSignal> signals = List<DbcSignal>.generate(8, (index) =>
          new DbcSignal(name: 'Byte ' + index.toString(),
              label: 'Byte ' + index.toString(),
              startBit: index * 8,
              bitLength: 8,
              isLittleEndian: true,
              isSigned: false,
              factor: 1,
              offset: 0,
              min: 0,
              max: 0,
              dataType: 'int',
              choking: false,
              visibility: true,
              interval: 0,
              category: 'Test',
              comment: 'byte',
              lineInDbc: 0,
              problems: List.empty(),
              sourceUnit: null,
              postfixMetric: null,
              states: List.empty()), growable: true);
          List<DbcSignal> signals2 = List<DbcSignal>.generate(4, (index) =>
          new DbcSignal(name: 'Long ' + index.toString(),
              label: 'Long ' + index.toString(),
              startBit: index * 16,
              bitLength: 16,
              isLittleEndian: true,
              isSigned: false,
              factor: 1,
              offset: 0,
              min: 0,
              max: 0,
              dataType: 'int',
              choking: false,
              visibility: true,
              interval: 0,
              category: 'Test',
              comment: 'long',
              lineInDbc: 0,
              problems: List.empty(),
              sourceUnit: null,
              postfixMetric: null,
              states: List.empty()));
          signals.addAll(signals2);
          dbc.signals.addAll(signals);
          dbcsTried.add(dbc);
        }
        dbcs.add(dbc);
      } catch (e) {
        List<DbcSignal> signals = List<DbcSignal>.generate(8, (index) =>
        new DbcSignal(name: 'Byte ' + index.toString(),
            label: 'Byte ' + index.toString(),
            startBit: index * 8,
            bitLength: 8,
            isLittleEndian: true,
            isSigned: false,
            factor: 1,
            offset: 0,
            min: 0,
            max: 0,
            dataType: 'int',
            choking: false,
            visibility: true,
            interval: 0,
            category: 'Test',
            comment: 'byte',
            lineInDbc: 0,
            problems: List.empty(),
            sourceUnit: null,
            postfixMetric: null,
            states: List.empty()), growable: true);
        List<DbcSignal> signals2 = List<DbcSignal>.generate(4, (index) =>
        new DbcSignal(name: 'Long ' + index.toString(),
            label: 'Long ' + index.toString(),
            startBit: index * 16,
            bitLength: 16,
            isLittleEndian: true,
            isSigned: false,
            factor: 1,
            offset: 0,
            min: 0,
            max: 0,
            dataType: 'int',
            choking: false,
            visibility: true,
            interval: 0,
            category: 'Test',
            comment: 'long',
            lineInDbc: 0,
            problems: List.empty(),
            sourceUnit: null,
            postfixMetric: null,
            states: List.empty()));
        signals.addAll(signals2);
        dbcsTried.add(new Dbc(canId: canId,
            pgn: 0,
            name: 'Test',
            label: 'Test',
            isExtendedFrame: false,
            dlc: 0,
            comment: 'Test',
            signals: signals));
      }
    });
  } else {
    dbcs = dbcsRead;
  }

  dbcs.sort((a, b) => a.name.compareTo(b.name));
  dbcs.forEach((dbc) {
    dbc.signals.sort((a, b) => a.name.compareTo(b.name));
  });

  if (useFake) {
    await simulateLogs();
  }

  return true;
}

Future<void> simulateLogs() async {
  if (fakeFile == null) {
    return;
  }
  
  serialLog = (await getStringFromAssets(fakeFile!)).split('\n').map((rawFrame) {
    if (rawFrame.length < 10 || rawFrame.startsWith('Time')) {
      return null;
    }

    try {
      return CanFrame.make(rawFrame.trim());
    } catch(e, stacktrace) {
      print("Fake CAN Frame error !\n" + rawFrame + "\n" + e.toString() + "\n" + stacktrace.toString());
      return null;
    }
  }).where((element) => element != null).toList();
  int serialLogCount = serialLog!.length;

  Timer.periodic(new Duration(milliseconds: 10), (timer) {
    if (useFake) {
      if (serialLogIndex >= serialLogCount) {
        serialLogIndex = 0;
      }

      CanFrame frame = serialLog![serialLogIndex++]!;

      int timestamp = frame.timestamp + 500;
      while (frame.timestamp < timestamp && serialLogIndex + 1 < serialLogCount) {
        // int i = 0;
        // while (i++ < 400 && serialLogIndex + 1 < serialLogCount) {
        frame.dateTimeReceived = DateTime.now();
        streamController.add(frame);
        // debugPrint(frame.toString());

        frame = serialLog![serialLogIndex++]!;
      }
    }
  });
}