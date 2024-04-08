import 'dart:async';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:alarm/alarm.dart';

import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';


import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Model/DataManager/SleepDataManager.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Widgets/Graphing.dart';

class SleepButton extends StatelessWidget {
  const SleepButton({Key? key, required this.onPressed}) : super(key: key);

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Icon(Icons.bedtime, size: 36),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}

 class SleepPage extends StatefulWidget {
  const SleepPage({super.key, required this.title});
  final String title;

  @override
  SleepPageState createState() => SleepPageState();
}

class SleepPageState extends State<SleepPage> {

  // timer to log sleep data from recent accelerometer and light data
  Timer? timer;
  Timer? accelerometerTimer;

  List<double>? _accelerometerValues; //accelerometer values
  

  Light? _light; //light sensor
  int? _luxValue; //light value

  // for graph
  List<double> accelerometerData = [];
  List<double> lightData = [];

  final _streamSubscriptions = <StreamSubscription<dynamic>>[]; //stream subscription

  @override
  void initState() {

    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => logSleepData());
    time = TimeOfDay.now();
    accelerometerTimer = Timer.periodic(const Duration(milliseconds: 250), (Timer t) => updateAccelerometerData());
    GetIt.instance<SleepDataManager>().addListener(update);

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            // add to our accelerometer data, average of x, y, z
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
        lightData.add(_luxValue!.toDouble());
        // remove first element if we have more than 20
        if (lightData.length > 20) {
          lightData.removeAt(0);
        }

      });
    },
    onError: (e) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Sensor Not Found"),
              content: Text(
                  "It seems that your device doesn't support Light Sensor"),
            );
          });
    },
    cancelOnError: true,
    
    ));
    } on LightException catch (e) {
      print(e);
    }
  }

    @override
  void dispose() {
    GetIt.instance<SleepDataManager>().removeListener(update);
    
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    


    timer?.cancel();
    super.dispose();
  }

  void update()
  {
    setState(() {
    }); //update the widget
  }

  void updateAccelerometerData()
  {
    // since new accelerometer data comes in only when the user moves the phone, we want to add the last accelerometer value to our data
    // add it as the magnitude of the x, y, z values
    if(_accelerometerValues == null || _accelerometerValues!.isEmpty)
    {
      return;
    }
    accelerometerData.add(sqrt(pow(_accelerometerValues![0], 2) + pow(_accelerometerValues![1], 2) + pow(_accelerometerValues![2], 2)));
    // remove first element if we have more than 20
    if (accelerometerData.length > 60) {
      accelerometerData.removeAt(0);
    }
  }

  void logSleepData()
  {
    // get average accelerometer value
    double accelerometerValue = 0;
    for(int i = 0; i < accelerometerData.length; i++)
    {
      accelerometerValue += (accelerometerData[i]).abs();
    }
    accelerometerValue /= accelerometerData.length;

    // get average light value

    bool lightDataAvailable = lightData.isNotEmpty;
    double lightValue = 0;
    for(int i = 0; i < lightData.length; i++)
    {
      lightValue += lightData[i];
    }
    lightValue /= lightData.length;

    // calculate sleep score
    // get our most recent sleep record to get the last sleep score
    SleepRecord? lastSleepRecord = GetIt.instance<SleepDataManager>().sleepRecords.lastOrNull;
    double lastSleepRecordScore = lastSleepRecord?.sleepScore ?? 0;
    // weight the accelerometer value more than the light value

    // adjust the accelerometer value to be between 0 and 1, clamp it to 0 and 1
    double adjustedAccelerometerValue = (accelerometerValue / 3).clamp(0, 1);
    // adjust the light value to be between 0 and 1, clamp it to 0 and 1
    double adjustedLightValue = (lightValue / 1000).clamp(0, 1);
    //weight each value
    adjustedAccelerometerValue *= 0.75;
    adjustedLightValue *= 0.25;
    // we want to have our sleep score be deltaed from the last sleep score
    double sleepScoreDelta = 100 / (adjustedAccelerometerValue + (lightDataAvailable ? adjustedLightValue : 0 ) + 1);
    // calculate the new sleep score by moving towards the delta
    double sleepScore = lastSleepRecordScore + (sleepScoreDelta - lastSleepRecordScore) / 100; // move 1% towards the delta
    // add to sleep data
    GetIt.instance<SleepDataManager>().addSleepRecord(SleepRecord(accelerometerValue, lightValue, DateTime.now().millisecondsSinceEpoch, sleepScore));
  }

  Alarm ?alarm;
  TimeOfDay time = TimeOfDay.now();

  void _selectTime()
  {
    showTimePicker(context: context, initialTime: time).then((value) => {
      if(value != null)
      {
        setState(() {
          time = value;
        })
      }
    });
  }

  void onSleep() async
  {
    // start sleep tracking
    // clear the accelerometer and light data
    accelerometerData.clear();
    lightData.clear();
    // clear the sleep data
    //GetIt.instance<SleepDataManager>().clearSleepRecords();
    DateTime now = DateTime.now();
    // set the date time for the alarm
    DateTime alarmDateTime = DateTime(now.year, now.month, now.day, time!.hour, time!.minute);
    if(alarmDateTime.isBefore(now))
    {
      // add a day if the alarm is before now
      alarmDateTime = alarmDateTime.add(const Duration(days: 1));
    }
    AlarmSettings alarmSettings = AlarmSettings(id: 42, dateTime: alarmDateTime, assetAudioPath: "assets/alarm.mp3",   loopAudio: true, vibrate: true, notificationTitle: 'Sleep Tracker +', notificationBody: 'Time to wake up!', fadeDuration: 3.0);
    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Widget build(BuildContext context) {
    // check if the user is authenticated
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    SleepRecord? lastSleepRecord = GetIt.instance<SleepDataManager>().sleepRecords.lastOrNull;
    final userAccelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    // get the last 10 sleep vaues from the sleep records
    List<double> sleepValues = [];
    for(int i = GetIt.instance<SleepDataManager>().sleepRecords.length - 1; i >= 0 && i >= GetIt.instance<SleepDataManager>().sleepRecords.length - 10; i--)
    {
      sleepValues.add(GetIt.instance<SleepDataManager>().sleepRecords[i].sleepScore);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep'),
      ),
      drawer : const NavigationPanel(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // select a time to wake up
            Column(
              children: <Widget>[
                TextButton(
                  onPressed: () => _selectTime(),
                  child: const Text('Select wake up time'),
                ),
                Text(
                  'Alarm set for: ${time.format(context)}',
                ),
              ],
            ),
            
            SleepButton(onPressed: onSleep),
            Text('User Accelerometer: ${userAccelerometer ?? 'Not Available'}'),
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(accelerometerData, 0, 3)),
            //Text('Light: ${_luxValue ?? 'Not Available'}'),
            //Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(lightData, 0, 1000)),
            Text('Sleep Score: ${lastSleepRecord?.sleepScore ?? 'Not Available'}'),
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(sleepValues, 0, 1000))
          ],
        ),
      ),
    );
  }
}