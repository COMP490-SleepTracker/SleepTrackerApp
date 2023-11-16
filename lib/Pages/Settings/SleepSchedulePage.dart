
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Widgets/SettingsButton.dart';
import '../NavigationPanel.dart';
import '../../Model/SettingsManager.dart';

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
    // load the start and end times from the settings manager for this weekday
    String wakeTime = GetIt.instance.get<SettingsManager>().getValue('sleep_schedule_${widget.weekday.index}_wake') as String;
    String sleepTime = GetIt.instance.get<SettingsManager>().getValue('sleep_schedule_${widget.weekday.index}_sleep') as String;

    TimeOfDay wakeTimeOfDay = TimeOfDay(hour: int.parse(wakeTime.split(':')[0]), minute: int.parse(wakeTime.split(':')[1]));
    TimeOfDay sleepTimeOfDay = TimeOfDay(hour: int.parse(sleepTime.split(':')[0]), minute: int.parse(sleepTime.split(':')[1]));

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

    // open a time picker for the start time
    Widget startTimePicker = SettingsButton(
      indent: 20,
        onPressed: () {
          showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          ).then(
            (value) {
              setState(() {
              });
              if(value != null)
                GetIt.instance.get<SettingsManager>().setValue('sleep_schedule_${widget.weekday.index}_wake', wakeTime);
            }
          );
        },
        child: Row(
          children: [
            Text('Wake Time $wakeTime'),
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
            initialTime: TimeOfDay.now(),
          ).then(
            (value){
              setState(() {
              });
              if(value != null)
                GetIt.instance.get<SettingsManager>().setValue('sleep_schedule_${widget.weekday.index}_sleep', sleepTime);
            }
          );
        },
        child: Row(
          children: [
            Text('Sleep Time $sleepTime'),
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