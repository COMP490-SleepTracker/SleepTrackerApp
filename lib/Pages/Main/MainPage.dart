import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/ScrollableTimePicker.dart';

import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

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
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
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
