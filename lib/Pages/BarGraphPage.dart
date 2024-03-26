import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/DataManager/SecureStorage.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_week.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_month.dart';

class BarGraphPage extends StatefulWidget{
  const BarGraphPage({super.key, required this.title});
  final String title;

  @override
  State<BarGraphPage> createState() => BarGraphPageState();
}

class BarGraphPageState extends State<BarGraphPage>{
  late DateTime today = setSunday(DateTime.now().toUtc());
  late DateTime selectedDay = setSunday(DateTime.now().toUtc());
  DateFormat df = DateFormat.Md();
  late String weekLabel = "${df.format(selectedDay)} - ${df.format(selectedDay.add(const Duration(days: 6)))}";

  List<HealthDataType> datatypes = [HealthDataType.SLEEP_SESSION];
  List<double> weeklyHours = [0,0,0,0,0,0,0];
  List<double> monthlySummary = [0,0,0,0,0];
  HashMap mapWeeks = HashMap<DateTime,List<double>>();
  HashMap mapAvgs = HashMap<DateTime,double>();
  double avgSlept = 0.0;
  double sleepDebt = 0.0;

  bool weekEnabled = true;
  bool monthEnabled = false; 

  @override
  void initState(){
    setSleepDebt();
    setChartWeek();
    deleteExtraWeeks();
    super.initState();
  }

    @override
  void dispose() {
    super.dispose();
  }


  ///Requests Sleep Session data for specified week beginning on [sunday] from Health Connect 
  ///and saves daily values into global [weeklyHours]
  ///
  ///Returns [double] value for the average hours slept on specified week
  Future<double> hoursSleptWeek(DateTime sunday) async {
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
    await health.requestAuthorization(datatypes);

    List<HealthDataPoint> healthdata = await health.getHealthDataFromTypes(sunday, sunday.add(const Duration(days: 8)), datatypes);
    //Trim out last weeks Saturday night sleep if it started after midnight
    healthdata = trimEnds(healthdata, sunday);
    fillBarChartWeek(healthdata);
    
    mapWeeks.putIfAbsent(sunday, () => weeklyHours);
    writeToStorage(sunday);
    return avgHoursWeek(sunday);
    }

  ///Writes [weeklyHours] into storage using [sunday] of a specific week as the key
  void writeToStorage(DateTime sunday) {
    if(today.isAfter(sunday) && sunday.isAfter(today.subtract(const Duration(days: 36)))) { //save week into storage if not current week AND is within the last 5 weeks
      SecureStorage().writeSecureData("Week - $sunday", "$weeklyHours");
    }
  }

  ///Returns the average hours slept for a given week and writes avg into memory.
  ///Only writes week into memory if it is within last 5 weeks
  double avgHoursWeek(DateTime selectedDay) {
    double totalSlept=0.0;
    double daysRecorded=0.0;
    
    for(int i = 0; i < weeklyHours.length; i++){
      if(weeklyHours[i] == 0) continue;
      totalSlept += weeklyHours[i];
      daysRecorded++;
    }
    if(totalSlept == 0.0) {
      mapAvgs.putIfAbsent(selectedDay, () => 0.0);
      if(today.isAfter(selectedDay) && selectedDay.isAfter(today.subtract(const Duration(days: 36)))) {
        SecureStorage().writeSecureData("Avg - $selectedDay", "0.0");
      }
      return 0.0;
      }
    double avg = totalSlept/daysRecorded/60;
    sleepDebt += (daysRecorded * 8) - (totalSlept/60);
    mapAvgs.putIfAbsent(selectedDay, () => avg);  
    if (today.isAfter(selectedDay) && selectedDay.isAfter(today.subtract(const Duration(days: 36)))) {
      SecureStorage().writeSecureData("Avg - $selectedDay", "$avg");
      SecureStorage().writeSecureData("SleepDebt", "$sleepDebt");
    }
    return mapAvgs[selectedDay];
  }

  ///Returns the [DateTime] object of midnight on Sunday of the calendar week of [selectedDay]
  DateTime setSunday(DateTime selectedDay) {
    int day = selectedDay.weekday; //Day of the week (Mon = 1, Tue = 2, ...)
    
    DateTime sunday = day < 7 ? 
    selectedDay.subtract(Duration(
      days: day, 
      hours: selectedDay.hour, 
      minutes: selectedDay.minute, 
      seconds: selectedDay.second,
      milliseconds: selectedDay.millisecond, 
      microseconds: selectedDay.microsecond)) : //Midnight of first calendar day(Sunday) of current week
    selectedDay.subtract(Duration(
      days: 7, 
      hours: selectedDay.hour, 
      minutes: selectedDay.minute, 
      seconds: selectedDay.second,
      milliseconds: selectedDay.millisecond, 
      microseconds: selectedDay.microsecond)); //current day is already Sunday, set to previous weeks Sunday
    
    if(selectedDay == sunday){
      sunday = sunday.subtract(const Duration(days: 7));
    }
    return sunday;
  }

  ///Retruns modified [List] of [HealthDataPoints] with the first and last entries trimmed out if they fall outside of desired week
  List<HealthDataPoint> trimEnds(List<HealthDataPoint> healthdata, DateTime sunday) {
      if (healthdata.isEmpty) return healthdata;
      if(healthdata[0].dateTo.isBefore(sunday.add(const Duration(days: 1))) && //Checks if first sleep of the week ended before Monday
         int.parse(healthdata[0].value.toString()) > 90){ //Only trims out sleep longer than 90mins to prevent trimming sunday naps
        healthdata.removeAt(0);
      }
      if (healthdata.isEmpty) return healthdata;
      if(healthdata.last.dateFrom.day != sunday.day && //last entry is not this sunday
      healthdata.last.dateFrom.weekday == 7 && //last entry was on next sunday
      healthdata.last.dateFrom.day != healthdata.last.dateTo.day){ // started on sunday, ended on monday
        healthdata.removeLast();
      }
      return healthdata;
    }

  ///Uses Health Connect data to populate [weeklyHours]
  void fillBarChartWeek(List<HealthDataPoint> healthdata) {
    weeklyHours = [0,0,0,0,0,0,0];
    if (healthdata.isEmpty) return;
      for(int i = 0; i < healthdata.length;i++){
        if(healthdata[i].dateFrom.day == healthdata[i].dateTo.day &&
          int.parse(healthdata[i].value.toString()) > 90){ //If sleep session occurred after midnight and was not a nap
            weeklyHours[healthdata[i].dateTo.weekday-1] += double.parse(healthdata[i].value.toString()); //Set that as previous night's sleep hours
        }
        else if(healthdata[i].dateFrom.day == healthdata[i].dateTo.day && int.parse(healthdata[i].value.toString()) <= 90){ //Nap defined at most 90 mins counts towards day it occurred
          if(healthdata[i].dateFrom.weekday == 7){ //If sunday (cant use weekday value)
            weeklyHours[0] += double.parse(healthdata[i].value.toString()); //nap hours added to sunday
          }
          else {
            weeklyHours[healthdata[i].dateFrom.weekday] += double.parse(healthdata[i].value.toString()); //nap hours added to day of the week
          }
        }
        else if(healthdata[i].dateFrom.weekday < 7){ //start was different day than end and did not start on Sunday
          weeklyHours[healthdata[i].dateFrom.weekday] += double.parse(healthdata[i].value.toString());
        }
        else{
          weeklyHours[0] += double.parse(healthdata[i].value.toString());
        }
      }
    }   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                ElevatedButton(
                  onPressed: monthEnabled ? buttonChange : null,
                  style: weekEnabled? const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.deepPurple)) : null, 
                  child: const Text("Week", style: TextStyle(color: Colors.white),)),
                ElevatedButton(
                  onPressed: weekEnabled ? buttonChange : null,
                  style: monthEnabled? const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.deepPurple)) : null, 
                  child: const Text("5 Week", style: TextStyle(color: Colors.white),),),
            ],),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              weekEnabled ? IconButton(onPressed: leftArrow, icon: const Icon(Icons.chevron_left)) : const SizedBox(height: 48,),
              Text(weekEnabled ? weekLabel : "Weekly Sleep Average", style: const TextStyle(fontSize: 24),),
              weekEnabled ? IconButton(onPressed: selectedDay != today ? rightArrow : null, icon: const Icon(Icons.chevron_right)) : const SizedBox()
          ],),
            Text("Average: ${tooltipText(avgSlept)}"),
            displayBars(),
            const Divider(),
            SizedBox( width: 300,height: 100, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                const Text("Sleep Debt", style: TextStyle(fontSize: 24)),
                Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                      Text("Total:",style: TextStyle(fontSize: 20),),
                      Text("This Week:",style: TextStyle(fontSize: 20),),
                      ],),
                      const SizedBox(width: 100,),
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(tooltipText(sleepDebt),style: const TextStyle(fontSize: 20),),
                      Text(tooltipText(setWeekDebt()),style: const TextStyle(fontSize: 20),),
                      ],),
                  ],
                ),
            ],),
            ),
            const Divider()
        ],),
        ),
      ),
    );
  }

  ///Returns container with conditional widgets which can change from 1 Week Graph to 5 Week Graph
  Widget displayBars() {
    return Container(
      height: 260,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.only(top: 35,bottom: 10), 
      child: weekEnabled ? BarGraphWeek(weeklySummary: weeklyHours) : BarGraphMonth(monthlySummary: monthlySummary)
    );
  }

  ///Toggles 1 Week Graph and 5 Week Graph
  void buttonChange() {
    weekEnabled = !weekEnabled;
    monthEnabled = !monthEnabled;
    if(weekEnabled){
      setChartWeek();
    }
    else{
      setChartMonth();
    }
  }

  ///Retrieves Health Connect data for specified week if it is not already in storage
  void setChartWeek() async {
      /*Reset weekly hours to 0 because loop adds onto existing value
        instead of setting value to account for naps*/
      weeklyHours = [0,0,0,0,0,0,0];
      avgSlept = 0;
      String value = await SecureStorage().readSecureData("Week - $selectedDay");
      String avg = await SecureStorage().readSecureData("Avg - $selectedDay");
      if(value != ''){
        weeklyHours = parseStorageValue(value);
        avgSlept = double.parse(avg);
      }else if(mapWeeks.containsKey(selectedDay)){
        weeklyHours = mapWeeks[selectedDay];
        avgSlept = mapAvgs[selectedDay];
      }
      else {
        avgSlept = await hoursSleptWeek(selectedDay);
      }
      weekLabel = "${df.format(selectedDay)} - ${df.format(selectedDay.add(const Duration(days: 6)))}";
      setState(() {setSleepDebt();});
  }

  ///Retrieves Health Connect data for last 5 weeks if they are not already in storage
  void setChartMonth() async {
    setState(() {});
    DateTime curr = setSunday(DateTime.now().toUtc());
    for(int i = 4; i >= 0; i-- ){
      String value = await SecureStorage().readSecureData("Avg - $curr");
      if(value != ''){
        monthlySummary[i] = double.parse(value);
      }
      else{
        monthlySummary[i] = await hoursSleptWeek(curr);
      }
      curr = curr.subtract(const Duration(days: 7));
  }
  setState(() {
    double total = 0.0;
    int daysRecorded = 0;
    for(int i = 0; i<monthlySummary.length; i++){
      if(monthlySummary[i] == 0) continue;
      total += monthlySummary[i];
      daysRecorded++;
    }
    if(daysRecorded > 0) {
      avgSlept = total/daysRecorded;
    }
  });
  }

  ///Converts [double] value of hours into String #0H #0m format
  String tooltipText(double hours){
    String hourText = '0';
    String minsText = '0';
    if(hours == 0.0) {
      return "0H 0m";
    } else if (hours >= 1) {
      hourText = hours.floor().toString();
      double mins = hours % hours.floor();
      minsText = (60 * mins).floor().toString();
    } else if(hours > 0 && hours < 1){
      hours+=1;
      double mins = hours % hours.floor();
      minsText = (60 * mins).floor().toString();
    } else if(hours < 0 && hours > -1){
      hours-=1;
      double mins = hours - hours.ceil();
      minsText = (60 * mins).ceil().toString();
    } else {
      hourText = hours.ceil().toString();
      double mins = hours - hours.ceil();
      minsText = (60*mins).ceil().toString();
    }
    return "${hourText}H ${minsText}m";
  }

  ///selected week moves backwards 1 week
  void leftArrow() {
    selectedDay = selectedDay.subtract(const Duration(days: 7));
    setChartWeek();
  }

  ///selected week moves forward 1 week
  void rightArrow() {
    selectedDay = selectedDay.add(const Duration(days: 7));
    setChartWeek();
  }
  
  ///Converts [String] value from storage into [List] of [double] values
  List<double> parseStorageValue(String value) {
   value = value.replaceAll(RegExp(r'[[\]]'), '');
   List<String> list = value.split(',');
   List<double> list2 = list.map(double.parse).toList();
   return list2;
  }
  
  ///Retrieves sleepDebt total from storage
  void setSleepDebt() async {
    String value = await SecureStorage().readSecureData("SleepDebt");
    if(value != '') {
      sleepDebt = double.parse(value);
    }
  }

  ///Calculates and returns sleepDebt for current selected Week
  double setWeekDebt(){
    int daysRecorded = 0;
    double total = 0;
    for(int i = 0; i < weeklyHours.length; i++){
      if(weeklyHours[i] != 0){
        total+= weeklyHours[i];
        daysRecorded++;
      }
    }
    if(total == 0) return 0;
    return (daysRecorded*8) - (total/60);
  }
  
  void deleteExtraWeeks() async{
    DateTime earliest = today.subtract(const Duration(days: 35));
    Map storageMap = await SecureStorage().readAll();

    for(dynamic key in storageMap.keys){
      if(key.contains('Week') || key.contains("Avg")){
        String temp = key.substring(key.indexOf('2'));
        if(DateTime.parse(temp).isBefore(earliest)){
          SecureStorage().deleteSecureData(key);
        }
        print(key);
      }
    }
  } 
}