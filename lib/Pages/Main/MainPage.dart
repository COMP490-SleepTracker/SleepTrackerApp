import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  static int hour = 1;
  static int minute = 0;
  static int amPm = 0;
  NumberFormat minutesFormat = NumberFormat("00");

  DateTime formatTime(){
    int fullHour = hour + amPm == 24 ? 12 : hour + amPm == 12 ? 0 : hour + amPm;
    DateTime alarm = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, fullHour, minute);
    if(alarm.isBefore(DateTime.now())){
      alarm = alarm.add(const Duration(days: 1));
    }
    return alarm;
  }

  String formatHour(int index){
    return index>9 ? '$index' : '  $index';
  }


  @override
  Widget build(BuildContext context) {
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    const style = TextStyle(fontSize: 40, color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              const Text('Set Alarm Time', style: TextStyle(fontSize: 24, )),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.bottomCenter,
                    end: AlignmentDirectional.topCenter,
                    stops: const [0, 0.5, 1],
                    colors: [Colors.black.withOpacity(.8), Colors.black.withOpacity(0), Colors.black.withOpacity(.8)]),
                  border:Border.all(
                    color: Colors.deepPurple,
                    width: 2.5
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(25))
                ),
                width: 240,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 70, maxHeight: 140),
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(initialItem: 7),
                          onSelectedItemChanged: (value) => hour = value + 1,
                          overAndUnderCenterOpacity: 0.3,
                          physics: const FixedExtentScrollPhysics(),
                          itemExtent: 50,
                          childDelegate: ListWheelChildLoopingListDelegate(
                              children: List<Widget>.generate(
                                  12,
                                  (index) => SizedBox(
                                      width: 60,
                                      child: Text(
                                        formatHour(index+1),
                                        style: style,
                                        textAlign: TextAlign.justify,
                                      ))))),
                    ),
                    const SizedBox(
                        height: 55,
                        child: Text(':', style: style, textAlign: TextAlign.center)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 70, maxHeight: 140),
                      child: ListWheelScrollView.useDelegate(
                          onSelectedItemChanged: (value) => minute = value * 5,
                          overAndUnderCenterOpacity: 0.3,
                          physics: const FixedExtentScrollPhysics(),
                          itemExtent: 50,
                          childDelegate: ListWheelChildLoopingListDelegate(
                              children: List<Widget>.generate(
                                  12,
                                  (index) => Text(minutesFormat.format(index * 5),
                                      style: style)))),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 70, maxHeight: 140),
                      child: ListWheelScrollView(
                          overAndUnderCenterOpacity: 0.3,
                          onSelectedItemChanged: (value) => amPm = (value * 12),
                          physics: const FixedExtentScrollPhysics(),
                          itemExtent: 50,
                          children: const <Widget>[
                            Text('AM', style: style),
                            Text(
                              'PM',
                              style: style,
                            )
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(24)),
            onPressed:() async {
              AlarmSettings alarmSettings = AlarmSettings(id: 42, dateTime: formatTime(), assetAudioPath: "assets/alarm.mp3",   loopAudio: true, vibrate: true, notificationTitle: 'Sleep Tracker +', notificationBody: 'Time to wake up!', volumeMax: true, fadeDuration: 3.0, stopOnNotificationOpen: true);
    await Alarm.set(alarmSettings: alarmSettings);
            },
            child: const Icon(Icons.bedtime_outlined, size: 36,) ),
            Text('Sleep', style: TextStyle(fontSize: 16),)
            ],
          ),
        ),
      )
    );
  }
}
