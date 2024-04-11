
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/UserDataManager.dart';
import 'package:sleeptrackerapp/Widgets/SettingsButton.dart';
import '../NavigationPanel.dart';

enum Weekday { Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, Count }
final List<String> weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class SleepScheduleEntry extends StatefulWidget {
  const SleepScheduleEntry(this.weekday, {super.key});

  final Weekday weekday;

  @override
  State<SleepScheduleEntry> createState() => _SleepScheduleEntryState();
}

class _SleepScheduleEntryState extends State<SleepScheduleEntry>
{
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isOpen = !isOpen;
          });
        },
        child: Row(
          children: [
            Text(weekdayNames[widget.weekday.index]),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );

    // get the UserDataManager
    UserDataManager userDataManager = GetIt.instance<UserDataManager>();

    String wakeTime = userDataManager.currentUser!.wakeTimes[widget.weekday.index];
    String sleepTime = userDataManager.currentUser!.sleepTimes[widget.weekday.index];

    


    // get the wake and sleep times (HH:MM, no AM/PM)
    TimeOfDay wakeTimeOfDay = TimeOfDay(hour: int.parse(wakeTime.split(':')[0]), minute: int.parse(wakeTime.split(':')[1]));
    TimeOfDay sleepTimeOfDay = TimeOfDay(hour: int.parse(sleepTime.split(':')[0]), minute: int.parse(sleepTime.split(':')[1]));

    Widget startTimePicker = SettingsButton(
      indent: 20,
        onPressed: () {
          showTimePicker(
            context: context,
            initialTime: wakeTimeOfDay,
          ).then((value) => 
            {
              if(value != null)
              {
                // update the wake time
                wakeTimeOfDay = value,
                // update the user data, write as HH:MM  (NO AM/PM), can't use format() because it adds AM/PM
                userDataManager.currentUser!.wakeTimes[widget.weekday.index] = '${wakeTimeOfDay.hour}:${wakeTimeOfDay.minute}',
                userDataManager.updateCurrentUser(userDataManager.currentUser!),
                // now update the widget
                setState(() {})
              }
            }
          );
        },
        child: Row(
          children: [
            Text('Wake Time: ${wakeTimeOfDay.format(context)}' ),
            const Spacer(),
            const Icon(Icons.timer),
          ],
    ));

    // open a time picker for the end time
    Widget endTimePicker = SettingsButton(
      indent: 20,
        onPressed: () {
          showTimePicker(
            context: context,
            initialTime: sleepTimeOfDay,
          ).then((value) => 
            {
              if(value != null)
              {
                // update the wake time
                sleepTimeOfDay = value,
                // update the user data
                userDataManager.currentUser!.sleepTimes[widget.weekday.index] = '${sleepTimeOfDay.hour}:${sleepTimeOfDay.minute}',
                userDataManager.updateCurrentUser(userDataManager.currentUser!),
                // now update the widget
                setState(() {})
              }
            }
          );
        },
        child: Row(
          children: [
            Text('Sleep Time: ${sleepTimeOfDay.format(context)}'),
            const Spacer(),
            const Icon(Icons.timer),
          ],
    ));

    // if we are open, show the dropdown menu, otherwise just show the button
    return isOpen ? Column(
      children: [
        button,
        startTimePicker,
        endTimePicker,
      ],
    ) : button;
  }
}



class SleepSchedulePage extends StatefulWidget {
  const SleepSchedulePage({super.key, required this.title});
  final String title;

  @override
  State<SleepSchedulePage> createState() => _SleepSchedulePageState();
}

class _SleepSchedulePageState extends State<SleepSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Schedule'),
        
      ),
      drawer : const NavigationPanel(),
      body: ListView.builder(
        itemCount: Weekday.Count.index,
        itemBuilder: (BuildContext context, int index) {
          return SleepScheduleEntry(Weekday.values[index]);
        },
    ));
  }
}