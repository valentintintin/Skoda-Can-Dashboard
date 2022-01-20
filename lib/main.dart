import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:skoda_can_dashboard/connections/fake_connection.dart';
import 'package:skoda_can_dashboard/connections/gvret_serial.dart';
import 'package:skoda_can_dashboard/connections/gvret_tcp.dart';
import 'package:skoda_can_dashboard/model/can_frame.dart';
import 'package:skoda_can_dashboard/model/dashcam_params.dart';
import 'package:skoda_can_dashboard/model/dbc.dart';
import 'package:skoda_can_dashboard/model/dbc_signal.dart';
import 'package:skoda_can_dashboard/model/frames/diagnosis_01_frame.dart';
import 'package:skoda_can_dashboard/widgets/pages/dashboard_page_widget.dart';
import 'package:skoda_can_dashboard/widgets/pages/dashcam_page_widget.dart';
import 'package:skoda_can_dashboard/widgets/pages/raw_serial_page_widget.dart';
import 'package:skoda_can_dashboard/utils.dart';

/*
 0x3EB : BIT 0 (checksum ?) / BIT 1 / BIT 2
 0x5E9 : BIT 5 ? 1 ?
 0x3DC : BIT 3 ? LONG 1 ?
 0x31B : BIT 2 & 3 = LONG 1
 0x3DA : BIT 4 ?
 0x65A : 0x0 0x0 0x0 0x1 0x0 0x0 0x3C 0x0 : switch Start & Stop
 
 - TODO Wrap des évènements (mode colonne mieux)
    
 - TODO Caméra : mettre une balance des blancs/expositions automatiques (et peut-être acheter une autre caméra normale)
    
 - TODO Interface Web pour récupérer les vidéos et les dump CAN
 - TODO Faire fonctionner le WiFi (depuis ESP) pour l'application Android
 
 
 - À tester : Enregistrement des vidéos en accéléré malgré les changements au processing
 - À tester : Kilométrage/litre/RPM/ACC vitesse/ACC activé/Levier de vitesse --> fausses valeures, bug décodage bytes   
 */

bool useFake = false;
bool useFilter = false;
bool saveFrames = false;
bool useDashcam = false;
String? dashcamParamsFile;
bool recordDashcam = false;
bool setDateTime = false;
String? fakeFile = 'assets/canbus.csv';
List<String> serialPorts = List.empty();
String? ipServer = null;
int portServer = 23;

List<Dbc> dbcs = List<Dbc>.empty(growable: true);
List<Dbc> dbcsTried = List<Dbc>.empty(growable: true);

late Stream<CanFrame> streamFrame;
late Stream<Image> streamPanelImage;
late Stream<Image> streamDashCamImage;
StreamController<CanFrame> streamControllerFrame = StreamController<CanFrame>.broadcast();
StreamController<Image> streamControllerPanelImage = StreamController<Image>.broadcast();
StreamController<Image> streamControllerDashCamImage = StreamController<Image>.broadcast();
StreamController<DashcamParams> streamControllerDashCamParams = StreamController<DashcamParams>.broadcast();

FakeConnection fakeConnection = FakeConnection(streamControllerFrame);
GvretSerial gvretSerial = GvretSerial(streamControllerFrame);
GvretTcp gvretTcp = GvretTcp(streamControllerFrame);

Process? dashcamPythonProgramProcess;

Future<void> initEnv() async {
  if (Platform.isLinux) {
    String env = Platform.environment['ENV'] ?? '';
    String dotEnvFile = '.env' + (env.length > 0 ? '.' + env : '');
    print('Take dotenv ' + dotEnvFile);
    await dotenv.load(fileName: dotEnvFile);

    useFake = dotenv.get('useFake') == 'true';
    useFilter = dotenv.get('useFilter') == 'true';
    saveFrames = dotenv.get('saveFrames') == 'true';
    useDashcam = dotenv.get('useDashcam') == 'true';
    dashcamParamsFile = dotenv.maybeGet('dashcamParamsFile', fallback: 'assets/dashcam_params.json');
    recordDashcam = dotenv.get('recordDashcam') == 'true';
    setDateTime = dotenv.get('setDateTime') == 'true';
    fakeFile = dotenv.maybeGet('fakeFile', fallback: 'assets/canbus.csv');
    serialPorts = dotenv.get('useSerialPort') == 'true' ? dotenv.get('serialPortDevices').split(',') : serialPorts;
    ipServer = dotenv.get('useSocket') == 'true' ? dotenv.get('ipServer') : ipServer;
    portServer = dotenv.get('useSocket') == 'true' ? int.parse(dotenv.get('portServer')) : portServer;
  } else {
    print('Platform Android, saveFrames = true and ipServer = 192.168.4.1');
    
    saveFrames = true;
    ipServer = '192.168.4.1';
  }
  
  if (saveFrames) {
    gvretSerial.enableSaveData();
  }
}

void tryConnect() {
  if (gvretSerial.isConnected() || gvretTcp.isConnected()) {
    return;
  }
  
  if (serialPorts.isNotEmpty) {
    try {
      gvretSerial.init(serialPorts);
      return;
    } catch (e) {
      print('Serial port error : ' + e.toString());    
    }
  }

  if (ipServer != null) {
    try {
      gvretTcp.init(ipServer!, portServer);
    } catch (e) {
      print('TCP error : ' + e.toString());
    }
  }
}

Future<void> main() async {
  await initEnv();

  streamFrame = streamControllerFrame.stream;
  streamPanelImage = streamControllerPanelImage.stream;
  streamDashCamImage = streamControllerDashCamImage.stream;

  WidgetsFlutterBinding.ensureInitialized();

  if (saveFrames) {
    String filePathFrames = await getNewFileName('canbus') + '.csv';
    print('Save frames to : ' + filePathFrames);
    File fileSave = File(filePathFrames);

    streamFrame.listen((event) {
      fileSave.writeAsStringSync(event.toCsv() + '\n', mode: FileMode.writeOnlyAppend);
    });
  }

  if (setDateTime) {
    print('Set datetime enabled');
    
    streamFrame.listen((event) async {
      if (event is Diagnosis01Frame) {
        int diffDateSeconds = (DateTime.now().millisecondsSinceEpoch - event.dateTime().millisecondsSinceEpoch).abs();
        if (diffDateSeconds >= 2 * 60 * 1000) {
          /*
          visudo
          pi ALL=(ALL) NOPASSWD:ALL
           */
          print('Current date : ' + DateTime.now().toIso8601String() + '    Event date : ' + event.dateTime().toIso8601String() + '   diff seconds : ' + diffDateSeconds.toString());
          
          try {
            await Process.run('./set_date.sh', [
              event.dateTime().toIso8601String(),
            ]).then((value) {
              if (value.stdout != null) {
                print('Date changed : ' + value.stdout);
              }
              
              if (value.stderr != null && value.stderr.toString().isNotEmpty) {
                print('Error date changed : ' + value.stderr);
              }
            });
          } catch (e, stacktrace) {
            print('Error before set date : ' + e.toString() + ' ' +
                stacktrace.toString());
          }
        }
      }
    });
  }

  await startDashcamImagesServer();

  runApp(FutureBuilder(
    future: computeFiles(),
    builder: (_, snap) {
      if (snap.hasError) {
        throw Exception(snap.error.toString() + ' : ' + snap.stackTrace.toString());
      }
      if(snap.hasData) {        
        tryConnect();

        Timer.periodic(new Duration(seconds: 7), (timer) {
          if (!gvretSerial.isConnected() || !gvretTcp.isConnected()) {
            tryConnect();
          } else {
            useFake = false;
          }
        });

        return MaterialApp(
            title: 'Skoda CAN Dashboard',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
            ),
            home: MyApp()
        );
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
  Widget bodyWidget = DashboardPage();
  DateTime? dateLastFrameReceived;
  final DateFormat dateFormatter = DateFormat('Hms');

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }

    Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        framesPerSeconds = nbFrames;
      });
      nbFrames = 0;
    });

    streamFrame.asBroadcastStream().listen((frame) {
      dateLastFrameReceived = frame.dateTimeReceived;
      nbFrames++;
    });
  }
  
  @override
  void dispose() {
    print(dashcamPythonProgramProcess?.toString());
    dashcamPythonProgramProcess?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon;
    if (gvretSerial.isConnected()) {
      connectionStateIcon = Icons.usb;
    } else if (gvretTcp.isConnected()) {
      connectionStateIcon = Icons.network_wifi;
    } else if (fakeConnection.isConnected()) {
      connectionStateIcon = Icons.pattern;
    } else {
      connectionStateIcon = Icons.mobiledata_off;
    }

    return Scaffold(
        drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                  ),
                  child: Image(image: AssetImage('assets/images/skoda.png'), width: 120, height: 120,),
                ),
                ListTile(
                  title: const Text('Dashboard'),
                  onTap: () {
                    setState(() {
                      bodyWidget = DashboardPage();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Raw Serial'),
                  onTap: () {
                    setState(() {
                      bodyWidget = RawSerialPage();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('DashCam'),
                  onTap: () {
                    setState(() {
                      bodyWidget = DashcamPage(streamDashCamImage, streamControllerDashCamParams, dashcamParamsFile!);
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Exit'),
                  onTap: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  },
                ),
              ],
            )
        ),
        appBar: AppBar(
          title: Text('Skoda CAN Dashboard'),
          actions: [
            Icon(connectionStateIcon),
            framesPerSeconds > 0 ?
            TextButton.icon(onPressed: () {},
                icon: Icon(Icons.stream),
                label: Text(
                  framesPerSeconds.toString() + ' FPS - Last at : ' + (dateLastFrameReceived != null ? dateFormatter.format(dateLastFrameReceived!) : '-'),
                  style: TextStyle(color: Colors.white),
                )
            )
                : SizedBox(),
            Padding(
                padding: EdgeInsets.only(left: 24, right: 24),
                child: Row(
                    children: [
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
        ),
        body: bodyWidget
    );
  }
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

  await fakeConnection.init(fakeFile!);
}

Future<void> startDashcamImagesServer() async {
  print('Serveur image panel on 38500');
  Future<ServerSocket> serverPanelImage = ServerSocket.bind('127.0.0.1', 38500);
  serverPanelImage.then((ServerSocket server) {
    server.listen((Socket socket) {
      socket.listen((List<int> data) {
        streamControllerPanelImage.add(Image.memory(Uint8List.fromList(data), gaplessPlayback: true,));
      });
    });
  });

  print('Serveur image on 38501');
  Future<ServerSocket> serverDashCamImage = ServerSocket.bind('127.0.0.1', 38501);
  serverDashCamImage.then((ServerSocket server) {
    server.listen((Socket socket) {
      streamControllerDashCamParams.stream.listen((params) async {
        List<int> json = utf8.encode(params.toRawJson());
        
        Uint8List length = Uint8List(2);
        ByteData bytedata = ByteData.view(length.buffer);

        bytedata.setUint8(0, json.length & 0xFF);
        bytedata.setUint8(1, (json.length & 0xFF00) >> 8);

        List<int> toSend = List.of(length, growable: true);
        toSend.addAll(json);
        
        socket.add(toSend);
      });
      
      socket.listen((List<int> data) {
        streamControllerDashCamImage.add(Image.memory(Uint8List.fromList(data), gaplessPlayback: true));
      });
    });
  });

  if (useDashcam) {
    print('Start dashcam/index_cam.py with params ' + (dashcamParamsFile ?? 'null'));

    await Process.run('sudo', ['pkill', 'python3']);
    
    try {
      dashcamPythonProgramProcess = await Process.start(
          'python3', ['dashcam/index_cam.py', dashcamParamsFile ?? 'params.json', recordDashcam ? '1' : '0'], mode: ProcessStartMode.detachedWithStdio);
      dashcamPythonProgramProcess!.stderr
          .transform(utf8.decoder)
          .forEach((e) {
        print('Error dashcam python: ' + e);
      });
      print('dashcam/index_cam.py started');
    } catch (e, stacktrace) {
      print('Error run dashcam python : ' + e.toString() + ' ' + stacktrace.toString());
    }
  }
}