import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  int rssi = 0;
  bool exists = false;

  int get size {
    return rssi > 60 ? 300 : (rssi * 5);
  }

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
        exists = result.beacons.length > 0;
      });

      if (result.beacons.length > 0) {
        this.setState(() {
          if (result.beacons[0].rssi != 0) rssi = 100 + result.beacons[0].rssi;
        });
        http.put(
            "https://dummy-beacon-flutter.firebaseio.com/ranging/$routeName.json",
            body: json
                .encode({"time": DateTime.now().toString(), "state": true}));
      } else {
        this.setState(() {
          rssi = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 100,
            ),
            exists
                ? Container(
                    height: size.toDouble(),
                    width: size.toDouble(),
                    decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        borderRadius: BorderRadius.circular(1000),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.greenAccent,
                              spreadRadius: 3,
                              offset: Offset.zero,
                              blurRadius: 5)
                        ]),
                  )
                : SpinKitRipple(
                    color: Colors.orange,
                    size: 250.0,
                    duration: Duration(milliseconds: 1300),
                  ),
            Container(),
          ],
        ),
      ),
    );
  }
}
