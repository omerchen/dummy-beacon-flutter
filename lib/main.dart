import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Beacon Test'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String status = "initializing..";
  @override
  void initState() {
    super.initState();
    initBeacon();
  }

  void initBeacon() async {
    try {
      this.setState(() {
        this.status = "0/2";
      });
      // if you want to manage manual checking about the required permissions
      //await flutterBeacon.initializeScanning;
      this.setState(() {
        this.status = "1/2";
      });
      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
      this.setState(() {
        this.status = "2/2";
      });
      // Configuring the beacon
      final regions = <Region>[];

      if (Platform.isIOS) {
        // iOS platform, at least set identifier and proximityUUID for region scanning
        regions.add(Region(
            identifier: 'FSC_BP104',
            proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
      } else {
        // Android platform, it can ranging out of beacon that filter all of Proximity UUID
        regions.add(Region(
            identifier: 'com.beacon',
            proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
      }
      // to start monitoring beacons

      flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
        // result contains a region, event type and event state
        if (result.monitoringState == MonitoringState.inside) {
          http.post(
              "https://dummy-beacon-flutter.firebaseio.com/monitoring/omer.json",
              body: json.encode({
                "time": DateTime.now().millisecondsSinceEpoch,
                "state": true
              }));
          print("INSIDE BEACON!");
          this.setState(() {
            this.status = "INSIDE!";
          });
        } else if (result.monitoringState == MonitoringState.outside) {
          http.post(
              "https://dummy-beacon-flutter.firebaseio.com/monitoring/omer.json",
              body: json.encode({
                "time": DateTime.now().millisecondsSinceEpoch,
                "state": false
              }));
          print("OUTSIDE BEACON!");
          this.setState(() {
            this.status = "OUTSIDE!";
          });
        } else {
          print("UNKOWN?!?!?!");
          this.setState(() {
            this.status = "UNKOWN?!?!";
          });
        }
      });
      this.setState(() {
        this.status = "waiting for beacon..";
      });
// to stop monitoring beacons
      //_streamMonitoring.cancel();
    } on PlatformException catch (e) {
      // library failed to initialize, check code and message
      print(
          "ERROR OCCURED!!!!!!!!!!!!! HELPP PLIZZZZZZ*&^*^&*&*&*&&*^&*^&**&*^&*&^&**%");
      this.setState(() {
        this.status = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              status,
            ),
          ],
        ),
      ),
    );
  }
}
