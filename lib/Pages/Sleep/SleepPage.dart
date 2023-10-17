import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';

import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key, required this.title});
  final String title;

  @override
  SleepPageState createState() => SleepPageState();
}

class SleepPageState extends State<SleepPage> {

  List<double>? _accelerometerValues; //accelerometer values
  Light? _light; //light sensor
  int? _luxValue; //light value


  final _streamSubscriptions = <StreamSubscription<dynamic>>[]; //stream subscription

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );

    //subscribe to light sensor
    _light = Light();
    try {
    _streamSubscriptions.add(_light!.lightSensorStream.listen((luxValue) {
      setState(() {
        _luxValue = luxValue;
      });
    }));
    } on LightException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAccelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep'),
      ),
      drawer : const NavigationPanel(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('User Accelerometer: ${userAccelerometer ?? 'Not Available'}'),
            Text('Light: ${_luxValue ?? 'Not Available'}'),
          ],
        ),
      ),
    );
  }
}