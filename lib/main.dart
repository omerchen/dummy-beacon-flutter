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
    var routeName = Platform.isIOS ? "iOS" : "android";
    try {
      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch (e) {
      // library failed to initialize, check code and message
    }
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
    } else {
      // Android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(
          identifier: 'com.beacon',
          proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
    }

    this.setState(() {
      url =
          "https://dummy-beacon-flutter.firebaseio.com/ranging/$routeName.json";
    });

// to start monitoring beacons
    flutterBeacon.monitoring(regions).listen((MonitoringResult result) {
      // result contains a region, event type and event state
      if (result.monitoringState == MonitoringState.inside) {
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
      } else if (result.monitoringState == MonitoringState.outside) {
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

    final regions2 = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions2.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions2.add(Region(
          identifier: 'com.beacon',
          proximityUUID: 'CC6ED3C0-477E-417B-81E1-0A62D6504061'));
    }

// to start ranging beacons
    flutterBeacon.ranging(regions2).listen((RangingResult result) {
      // result contains a region and list of beacons found
      // list can be empty if no matching beacons were found in range
      this.setState(() {
        ranging = "ranging: ${(result.beacons.length)}";
      });

      if (result.beacons.length > 0) {
        http
            .put(
                "https://dummy-beacon-flutter.firebaseio.com/ranging/$routeName.json",
                body: json.encode({
                  "time": DateTime.now().toString(),
                  "state": true
                }))
            .then((value) {
          this.setState(() {
            lastStatus = value.statusCode.toString();
            lastTime = DateTime.now().toString();
          });
        }).catchError((e) {
          this.setState(() {
            lastStatus = "error!";
            lastTime = e.toString();
          });
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
