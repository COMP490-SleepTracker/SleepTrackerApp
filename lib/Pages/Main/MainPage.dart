import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/ScrollableTimePicker.dart';

import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

import 'package:firebase_auth/firebase_auth.dart';





// import 'package:firebase_database/firebase_database.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  late DateTime alarmTime;

  @override
  Widget build(BuildContext context) {
    testThis() async {
              final now = DateTime.now();
              final midnight = DateTime(now.year, now.month, now.day);
              final yesterday = now.subtract(Duration(hours: 24));
              final midnight2 = DateTime(yesterday.year, yesterday.month, yesterday.day);

       HealthConnect e = GetIt.instance<HealthConnect>();  
        List<HealthDataPoint>? test = await e.ReadRawData([HealthDataType.STEPS],midnight, now);
        print("========================================================================================================");
        print('now $now');
        print(' yesterday $yesterday');
        print('midnight $midnight');


        String totalSteps = await e.returnTotal(HealthDataType.STEPS,yesterday,midnight);
        print("TOTAL STEPS $totalSteps");

        // String avgHeart = await e.returnTotal(HealthDataType.HEART_RATE,midnight,now);
        // print("avgHeartRate $avgHeart");

        // String totalDeep = await e.returnTotal(HealthDataType.SLEEP_REM,yesterday,now);
        // print("DEEP $totalDeep");
  }

    final user = FirebaseAuth.instance.currentUser; 
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    } else {
      //testDB();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body: SafeArea(
        child: Align(
          alignment: const AlignmentDirectional(0,0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              const Text('Set Alarm Time', style: TextStyle(fontSize: 24)),
              ScrollableTimePicker(
                borderColor: Colors.deepPurple, 
                onTimeChange:(time) => alarmTime = time,
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(), 
                    padding: const EdgeInsets.all(24)),
                  onPressed: setAlarm, 
                  child: const Icon(Icons.bedtime_outlined, size: 36)),
                  const Text('Sleep', style: TextStyle(fontSize: 16),)
            ],
          ),
        )
      )
    );
  }

  void setAlarm() async {
    AlarmSettings alarmSettings = AlarmSettings(
      id: 42, 
      dateTime: 
      alarmTime, 
      assetAudioPath: "assets/alarm.mp3",   
      loopAudio: true, 
      vibrate: true, 
      notificationTitle: 'Sleep Tracker +', 
      notificationBody: 'Time to wake up!', 
      volumeMax: true, 
      fadeDuration: 3.0, 
      stopOnNotificationOpen: true);
    await Alarm.set(alarmSettings: alarmSettings);
  }
}


