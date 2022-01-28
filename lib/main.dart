import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:skoda_can_dashboard/client_websocket.dart';
import 'package:skoda_can_dashboard/model/dashcam_params.dart';
import 'package:skoda_can_dashboard/model/vehicle_state.dart';
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

// String? dashcamParamsFile;
// bool useDashcam = false;
// bool recordDashcam = false;
String? ipServer = null;
int portServer = 8080;

late Stream<VehicleState> streamVehicleState;
late Stream<Image> streamPanelImage;
late Stream<Image> streamDashCamImage;
StreamController<VehicleState> streamControllerVehicleState = StreamController<VehicleState>.broadcast();
StreamController<Image> streamControllerPanelImage = StreamController<Image>.broadcast();
StreamController<Image> streamControllerDashCamImage = StreamController<Image>.broadcast();
StreamController<DashcamParams> streamControllerDashCamParams = StreamController<DashcamParams>.broadcast();

ClientWebsocket clientWebsocket = ClientWebsocket(streamControllerVehicleState);

Process? dashcamPythonProgramProcess;

Future<void> initEnv() async {
  if (Platform.isLinux) {
    String env = Platform.environment['ENV'] ?? '';
    String dotEnvFile = '.env' + (env.length > 0 ? '.' + env : '');
    print('Take dotenv ' + dotEnvFile);
    await dotenv.load(fileName: dotEnvFile);

    // dashcamParamsFile = dotenv.maybeGet('dashcamParamsFile', fallback: 'assets/dashcam_params.json');
    // recordDashcam = dotenv.get('recordDashcam') == 'true';
    ipServer = dotenv.get('ipServer');
    portServer = int.parse(dotenv.get('portServer'));
  } else {
    print('Platform Android, saveFrames = true and ipServer = 192.168.4.1');
    
    ipServer = '192.168.4.1';
  }
}

void tryConnect() {
  if (clientWebsocket.isConnected()) {
    return;
  }
  
  if (ipServer != null) {
    clientWebsocket.init(ipServer!, portServer, 'vehicle_state');
  }
}

Future<void> main() async {
  await initEnv();

  streamVehicleState = streamControllerVehicleState.stream;
  streamPanelImage = streamControllerPanelImage.stream;
  streamDashCamImage = streamControllerDashCamImage.stream;

  WidgetsFlutterBinding.ensureInitialized();

  // await startDashcamImagesServer();

  tryConnect();

  Timer.periodic(new Duration(seconds: 3), (timer) {
    tryConnect();
  });

  runApp(MaterialApp(
      title: 'Skoda CAN Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyApp()
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

    streamVehicleState.asBroadcastStream().listen((frame) {
      dateLastFrameReceived = frame.dateTime;
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
/*    if (gvretSerial.isConnected()) {
      connectionStateIcon = Icons.usb;
    } else*/ if (clientWebsocket.isConnected()) {
      connectionStateIcon = Icons.network_wifi;
    } /*else if (fakeConnection.isConnected()) {
      connectionStateIcon = Icons.pattern;
    } */else {
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
                // ListTile(
                //   title: const Text('Raw Serial'),
                //   onTap: () {
                //     setState(() {
                //       bodyWidget = RawSerialPage();
                //     });
                //     Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: const Text('DashCam'),
                //   onTap: () {
                //     setState(() {
                //       bodyWidget = DashcamPage(streamDashCamImage, streamControllerDashCamParams, dashcamParamsFile!);
                //     });
                //     Navigator.pop(context);
                //   },
                // ),
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

// Future<void> startDashcamImagesServer() async {
//   print('Serveur image panel on 38500');
//   Future<ServerSocket> serverPanelImage = ServerSocket.bind('127.0.0.1', 38500);
//   serverPanelImage.then((ServerSocket server) {
//     server.listen((Socket socket) {
//       socket.listen((List<int> data) {
//         streamControllerPanelImage.add(Image.memory(Uint8List.fromList(data), gaplessPlayback: true,));
//       });
//     });
//   });
//
//   print('Serveur image on 38501');
//   Future<ServerSocket> serverDashCamImage = ServerSocket.bind('127.0.0.1', 38501);
//   serverDashCamImage.then((ServerSocket server) {
//     server.listen((Socket socket) {
//       streamControllerDashCamParams.stream.listen((params) async {
//         List<int> json = utf8.encode(params.toRawJson());
//        
//         Uint8List length = Uint8List(2);
//         ByteData bytedata = ByteData.view(length.buffer);
//
//         bytedata.setUint8(0, json.length & 0xFF);
//         bytedata.setUint8(1, (json.length & 0xFF00) >> 8);
//
//         List<int> toSend = List.of(length, growable: true);
//         toSend.addAll(json);
//        
//         socket.add(toSend);
//       });
//      
//       socket.listen((List<int> data) {
//         streamControllerDashCamImage.add(Image.memory(Uint8List.fromList(data), gaplessPlayback: true));
//       });
//     });
//   });
//
//   if (useDashcam) {
//     print('Start dashcam/index_cam.py with params ' + (dashcamParamsFile ?? 'null'));
//
//     await Process.run('sudo', ['pkill', 'python3']);
//    
//     try {
//       dashcamPythonProgramProcess = await Process.start(
//           'python3', ['dashcam/index_cam.py', dashcamParamsFile ?? 'params.json'], mode: ProcessStartMode.detachedWithStdio);
//       dashcamPythonProgramProcess!.stderr
//           .transform(utf8.decoder)
//           .forEach((e) {
//         print('Error dashcam python: ' + e);
//       });
//       print('dashcam/index_cam.py started');
//     } catch (e, stacktrace) {
//       print('Error run dashcam python : ' + e.toString() + ' ' + stacktrace.toString());
//     }
//   }
// }