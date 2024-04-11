import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/DataManager/UserDataManager.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/ScrollableTimePicker.dart';
import 'package:sleeptrackerapp/Model/DataManager/SecureStorage.dart';

import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



// import 'package:firebase_database/firebase_database.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  late DateTime alarmTime;
  late String alarmFilename;
  late double alarmVolume;
  late bool vibrationSetting;
  late Future<bool> alarmSet;

  DateTime getDefaulTime() 
  {
    UserDataEntry? user = GetIt.instance<UserDataManager>().currentUser;
    if(user != null)
    {

      // first we need to get the day of the week
      int day = DateTime.now().weekday - 1;

      // get the wake up time for the day
      String todayWakeTime = user.wakeTimes[day];
      TimeOfDay todayWakeTimeOfDay = TimeOfDay(hour: int.parse(todayWakeTime.split(':')[0]), minute: int.parse(todayWakeTime.split(':')[1]));

      TimeOfDay now = TimeOfDay.now();

      // check if the current time is past the wake up time, if it is, we want to set the wake up time to the next day
      if(now.hour > todayWakeTimeOfDay.hour || (now.hour == todayWakeTimeOfDay.hour && now.minute > todayWakeTimeOfDay.minute))
      {
        // this means we want to set the wake up time to the next day
        int nextDay = (day + 1) % 7;
        String nextDayWakeTime = user.wakeTimes[nextDay];
        TimeOfDay nextDayWakeTimeOfDay = TimeOfDay(hour: int.parse(nextDayWakeTime.split(':')[0]), minute: int.parse(nextDayWakeTime.split(':')[1]));

        // we need to return the next day wake time, so tomorrow's wake time
        return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, nextDayWakeTimeOfDay.hour, nextDayWakeTimeOfDay.minute);
      }
      // this means we want to set the wake up time to today
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, todayWakeTimeOfDay.hour, todayWakeTimeOfDay.minute);
    }
    return DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    alarmTime = getDefaulTime();
    alarmSet = readStorage();   

  }

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
  setNotification();

    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the login 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }


    // now we need to get the next alarm time


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body: SafeArea(
        child: Align(
          alignment: const AlignmentDirectional(0,0),

          child: FutureBuilder(
            future: alarmSet,
            builder: (context,snapshot) {
              if(snapshot.hasData){
                bool alarmset = snapshot.data as bool;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  const Text('Set Alarm Time', style: TextStyle(fontSize: 24)),
                  ScrollableTimePicker(
                    borderColor: Colors.deepPurple, 
                    onTimeChange:(time) => alarmTime = time,
                    defaultTime: alarmTime,
                    ),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(), 
                        padding: const EdgeInsets.all(24)),
                      onPressed: !alarmset ? setAlarm : stopAlarm, 
                      child: !alarmset ? const Icon(Icons.bedtime_outlined, size: 36) : const Icon(Icons.cancel, size: 36)),
                      Text(!alarmset ? 'Sleep' : 'Stop Alarm', style: const TextStyle(fontSize: 16),),
                ],
              );}
              else{
                return const CircularProgressIndicator();
              }
            }
          ),
        )
      )
    );
  }

  void stopAlarm() async {
    await Alarm.stop(42);
    setState(() {
  alarmSet = alarmState(false);
});
  }

  void setAlarm() async {
    await Alarm.init();
    final alarmSettings = AlarmSettings(
      id: 42,
      volume: alarmVolume, 
      vibrate: vibrationSetting,
      dateTime: alarmTime, 
      assetAudioPath: 'assets/$alarmFilename',
      loopAudio: true,
      notificationTitle: 'SleepTracker +', 
      notificationBody: 'Time to wake up!');
    
    // show a notification that the alarm has been set
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alarm has been set')));

  void setNotification() async {

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails('alarm_notif', 'alarm_notif' , channelDescription: 'channel for alarm notifications', importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );



    DateTime sleepTime = DateTime.now();
    UserDataEntry? user = GetIt.instance<UserDataManager>().currentUser;
    if(user != null)
    {
      int day = DateTime.now().weekday - 1;
      String todaySleepTime = user.sleepTimes[day];
      sleepTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(todaySleepTime.split(':')[0]), int.parse(todaySleepTime.split(':')[1]));
    }


    tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, sleepTime.year, sleepTime.month, sleepTime.day, sleepTime.hour, sleepTime.minute);
    if(scheduledTime.isBefore(tz.TZDateTime.now(tz.local)))
    {
      // if the time is in the past, get the next day's sleep time instead
      int day = (DateTime.now().weekday - 1 + 1) % 7;
      String nextDaySleepTime = user!.sleepTimes[day];
      sleepTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, int.parse(nextDaySleepTime.split(':')[0]), int.parse(nextDaySleepTime.split(':')[1]));

      scheduledTime = tz.TZDateTime(tz.local, sleepTime.year, sleepTime.month, sleepTime.day, sleepTime.hour, sleepTime.minute);
    }

    await FlutterLocalNotificationsPlugin().zonedSchedule(42, 'Sleep Tracker +', 'Time to sleep!', scheduledTime, platformChannelSpecifics, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  }

    await Alarm.set(alarmSettings: alarmSettings);
    setState(() {
  alarmSet = alarmState(true);
});
  }

  
  
  Future<bool> readStorage() async {
    alarmFilename = await SecureStorage().readSecureData("Alarm-Choice");
    if(alarmFilename == "") {
      alarmFilename = "alarm.mp3";
      SecureStorage().writeSecureData("Alarm-Choice", "alarm.mp3");
      }
    String volumeString = await SecureStorage().readSecureData("Alarm-Volume");
    if(volumeString == ""){
      volumeString = "50";
      SecureStorage().writeSecureData("Alarm-Volume", "50");
      }
    if(volumeString == "0"){alarmVolume = 0;}
    else{alarmVolume = double.parse(volumeString)/100;}
    String vibrationString = await SecureStorage().readSecureData("Alarm-Vibration");
    if(vibrationString == ""){vibrationSetting = true; SecureStorage().writeSecureData("Alarm-Vibration", "true");}
    else{vibrationSetting = bool.parse(vibrationString);}

    return Alarm.hasAlarm() ? true : false;
  }
  
  Future<bool> alarmState(bool bool) async {
    return bool;
  }
}


