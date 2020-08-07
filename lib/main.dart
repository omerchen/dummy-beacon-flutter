import 'dart:io';

import 'package:beacons/beacons.dart';
import 'package:flutter/material.dart';
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
      title: 'Beacon Test V3',
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
  String status2 = "initializing..";
  String ranging = "ranging: 0";
  String lastTime = "-";
  String lastStatus = "-";
  String url = "-";

  @override
  void initState() {
    super.initState();
    initBeacon();
  }

    void initBeacon() async {
    String routeName = Platform.isIOS?"IOS2":"android2";
    Beacons.monitoring(
      region: new BeaconRegionIBeacon(
        identifier: 'test',
        proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061',
      ),
      inBackground: true,
    ).listen((result) {

// result contains a region, event type and event state
      if (result.event == MonitoringState.enterOrInside) {
        http.post(
            "https://dummy-beacon-flutter.firebaseio.com/monitoring/$routeName.json",
            body: json.encode({
              "time": DateTime.now().toString(),
              "state": true
            }));
        print("INSIDE BEACON!");
        this.setState(() {
          this.status = "INSIDE!";
          this.status2 = "INSIDE!";
        });
      } else if (result.event == MonitoringState.exitOrOutside) {
        http.post(
            "https://dummy-beacon-flutter.firebaseio.com/monitoring/$routeName.json",
            body: json.encode({
              "time": DateTime.now().toString(),
              "state": false
            }));
        print("OUTSIDE BEACON!");
        this.setState(() {
          this.status = "OUTSIDE!";
          this.status2 = "OUTSIDE!";
        });
      } else {
        print("UNKOWN?!?!?!");
        this.setState(() {
          this.status = "UNKOWN?!?!";
        });
      }















    });
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
            Text(
              status2,
            ),
            Text(
              ranging,
            ),
            Text(
              lastStatus,
            ),
            Text(
              lastTime,
            ),
            Text(
              url,
            ),
          ],
        ),
      ),
    );
  }
}
