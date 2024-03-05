import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_week.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_month.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';

class testRetrieve extends StatefulWidget{
  const testRetrieve({super.key, required this.title});
  final String title;

  @override
  State<testRetrieve> createState() => testRetrieveState();
}

class testRetrieveState extends State<testRetrieve>{
  late DateTime selectedDay = setSunday(DateTime.now());
  late  Future<List<HealthDataPoint>> sleepData;
  DateFormat df = DateFormat.Md();
  String weekLabel = "1/1 - 1/7";
  var f = NumberFormat("#0.0#", "en_US");

  HealthConnect e = GetIt.instance<HealthConnect>();
  List<HealthDataType> list = [HealthDataType.SLEEP_SESSION];
  List<double> weeklyHours = [0,0,0,0,0,0,0];
  HashMap mapWeeks = HashMap<DateTime,List<double>>();
  HashMap mapAvgs = HashMap<DateTime,double>();
  double avgSlept = 0.0;

  bool weekEnabled = true;
  bool monthEnabled = false; 

  List<double> monthlySummary = [0,0,0,0,0]; //Dummy data

  @override
  void initState(){
    setChartWeek();
    super.initState();
  }

    @override
  void dispose() {
    super.dispose();
  }

  Future<List<HealthDataPoint>> hoursSleptWeek(DateTime sunday) async {
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
    await health.requestAuthorization(list);

    List<HealthDataPoint> healthdata = await health.getHealthDataFromTypes(sunday, sunday.add(const Duration(days: 8)), list);
    if(healthdata.isEmpty){
      mapWeeks.putIfAbsent(sunday, () => [0.0,0.0,0.0,0.0,0.0,0.0,0.0]);
      avgHoursWeek();
      return healthdata = List.empty();
    }

    //Trim out last weeks Saturday night sleep if it started after midnight
    healthdata = trimEnds(healthdata, sunday);
    fillBarChartWeek(healthdata);
    mapWeeks.putIfAbsent(sunday, () => weeklyHours);
    avgHoursWeek();
    
    return healthdata;
    }

  void avgHoursWeek() {
    if(mapAvgs.containsKey(selectedDay)){
      avgSlept = mapAvgs[selectedDay];
      return;
    }
    double totalSlept=0.0;
    double daysRecorded=0.0;
    
    for(int i = 0; i < weeklyHours.length; i++){
      if(weeklyHours[i] == 0) continue;
      totalSlept += weeklyHours[i];
      daysRecorded++;
    }
    if(totalSlept == 0.0) {
      avgSlept = 0.0;
      mapAvgs.putIfAbsent(selectedDay, () => avgSlept);
      return;
      }
    
    avgSlept = totalSlept/daysRecorded/60;
    mapAvgs.putIfAbsent(selectedDay, () => avgSlept);
  }

  DateTime setSunday(DateTime currentDay) {
    int day = currentDay.weekday; //Day of the week (Mon = 1, Tue = 2, ...)
    
    DateTime sunday = day < 7 ? 
    currentDay.subtract(Duration(
      days: day, 
      hours: currentDay.hour, 
      minutes: currentDay.minute, 
      seconds: currentDay.second,
      milliseconds: currentDay.millisecond, 
      microseconds: currentDay.microsecond)) : //Midnight of first calendar day(Sunday) of current week
    currentDay.subtract(Duration(
      days: 7, 
      hours: currentDay.hour, 
      minutes: currentDay.minute, 
      seconds: currentDay.second,
      milliseconds: currentDay.millisecond, 
      microseconds: currentDay.microsecond)); //current day is already sunday, show previous week
    
    if(currentDay == sunday){
      sunday = sunday.subtract(const Duration(days: 7));
    }
    return sunday;
  }

  List<HealthDataPoint> trimEnds(List<HealthDataPoint> healthdata, DateTime sunday) {
      if (healthdata.isEmpty) return healthdata;
      if(healthdata[0].dateTo.isBefore(sunday.add(const Duration(days: 1))) && //Checks if first sleep of the week ended before Monday
         int.parse(healthdata[0].value.toString()) > 90){ //Only trims out sleep longer than 90mins to prevent trimming sunday naps
        healthdata.removeAt(0);
      }
      
      if(healthdata.last.dateFrom.day != sunday.day && //last entry is not this sunday
      healthdata.last.dateFrom.weekday == 7 && //last entry was on next sunday
      healthdata.last.dateFrom.day != healthdata.last.dateTo.day){ // started on sunday, ended on monday
        healthdata.removeLast();
      }
      return healthdata;
    }

  void fillBarChartWeek(List<HealthDataPoint> healthdata) {
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
      body: FutureBuilder(
        builder:(context, snapshot) {
            return Scaffold(
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
                    weekEnabled ? IconButton(onPressed: rightArrow, icon: const Icon(Icons.chevron_right)) : const SizedBox()
                ],),
                  Text("Average: ${f.format(avgSlept)}"),
                  displayBars(),
                  const Divider(),
                  const SizedBox( width: 300,height: 100, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      Text("Sleep Debt", style: TextStyle(fontSize: 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("Total:            "),Text("This Week:            "), Text("This Month:            ")],),
                        Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("12.1"" Hours     "), Text("-3.7"" Hours     "), Text("+8.2"" Hours     ")],)
                    ],),
                  ],),
                  ),
                  const Divider()
              ],),
              ),
            );
          
        }, future: sleepData,
      ),
    );
  }

  Widget displayBars() {
   
      return Container(
        height: 260,
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.only(top: 60,bottom: 10), 
        child: weekEnabled ? BarGraphWeek(weeklySummary: weeklyHours) : BarGraphMonth(monthlySummary: monthlySummary)
        );
       
    
  }

  void buttonChange() {
    weekEnabled = !weekEnabled;
    monthEnabled = !monthEnabled;
    if(weekEnabled){
      setChartWeek();
    }
    else if(monthEnabled){
      setChartMonth();
    }
  }

  void setChartWeek() {
    setState(() {
      /*Reset weekly hours to 0 because loop adds onto existing value
        instead of setting value to account for naps */
      weeklyHours = [0,0,0,0,0,0,0];
      avgSlept = 0;
      if(mapWeeks.containsKey(selectedDay)){
        weeklyHours = mapWeeks[selectedDay];
        avgHoursWeek();
      }
      else {
        sleepData = hoursSleptWeek(selectedDay);
      }
      weekLabel = "${df.format(selectedDay)} - ${df.format(selectedDay.add(const Duration(days: 6)))}";
    });
  }

  Future<void> setChartMonth() async {
    DateTime curr = setSunday(DateTime.now());
    setState(() {
      for(int i = 4; i >= 0; i-- ){
        if(mapAvgs.containsKey(curr)){
          monthlySummary[i] = mapAvgs[curr];
        }
        else{
          monthlySummary[i] = 6.5;
        }
        curr = curr.subtract(const Duration(days: 7));
      }
      
    });
  }

  void leftArrow() {
    selectedDay = selectedDay.subtract(const Duration(days: 7));
    setChartWeek();
  }

  void rightArrow() {
    selectedDay = selectedDay.add(const Duration(days: 7));
    setChartWeek();
  }
  
}