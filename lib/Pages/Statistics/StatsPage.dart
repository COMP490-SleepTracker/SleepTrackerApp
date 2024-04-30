
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/HealthStuff/SleepRequest.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/Analysis.dart';
import 'package:sleeptrackerapp/Widgets/SleepScore.dart';
import 'package:sleeptrackerapp/Widgets/StepGraph.dart';
import 'package:sleeptrackerapp/Widgets/heartRate.dart';
import 'package:sleeptrackerapp/Widgets/tipsPage.dart';

class tempStatsPage extends StatefulWidget {
const tempStatsPage({super.key, 
required this.title, 
this.weekday = 0,
this.sunday,
this.request
});

  final String title;
  final int weekday;
  final DateTime? sunday;
  final SleepRequest? request;
  
  @override
  State<tempStatsPage> createState() => tempStatsPageState();
}

class tempStatsPageState extends State<tempStatsPage>{
  late SleepRequest request;
  bool ready = false;
  bool stepGraphReady = false;
  bool heartGraphReady = false;
  DateTime today = DateTime.now();
  final DateFormat yMd = DateFormat.yMd();
  late DateTime selectedDay;
  late DateTime sunday;
  late List<double> scores;
  late int index;
  final TextStyle dateStyle = const TextStyle(fontSize: 24, decoration: TextDecoration.underline, fontWeight: FontWeight.w500);
  
   @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  initState(){
    setDateStartup();
    setScoresStartup();
    super.initState();
  }
  
  @override
  void dispose(){
    super.dispose();
  }

  void setDateStartup(){
    today = DateTime(today.year,today.month,today.day);
    DateTime temp = (widget.sunday ?? today);
    selectedDay = temp.add(Duration(days: widget.weekday));
    sunday = setSunday(selectedDay);
    index = selectedDay.difference(sunday).inDays;
  }

  void setScoresStartup() async {
    request = (widget.request ?? SleepRequest());
    if(widget.request == null){
      await requestData();
    }
    scores = request.weekScores;
    setState(() {ready = true;});
    if(request.sleepPoints.isEmpty) {
      await request.stepGraphData(sunday);
    }
    setState(() {stepGraphReady = true;});
    await request.getHeartRate(index);
    setState(() {heartGraphReady = true;});
  }

  DateTime setSunday(DateTime selectedDay) {
    int day = selectedDay.weekday; //Day of the week (Mon = 1, Tue = 2, ...)
    DateTime sunday = selectedDay;
    if(day < 7){sunday = selectedDay.subtract(Duration(days: day));}

    sunday = DateTime(sunday.year,sunday.month,sunday.day);
    return sunday;
  } 

  Future<void> calendar() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: today);

    if(picked != null){
      selectedDay = picked;
      DateTime tempSunday = setSunday(selectedDay);
      if(sunday != tempSunday){
        sunday = tempSunday;
        await updateWeek();
      }
      index = selectedDay.difference(sunday).inDays;
      setState(() {ready = stepGraphReady = true; heartGraphReady = false;});
      await request.getHeartRate(index);
      setState(() {heartGraphReady = true;});
    }
    }

    leftArrow() async{
      selectedDay = DateTime(selectedDay.year,selectedDay.month,selectedDay.day-1);
      if(index == 0){
        index = 6; sunday = setSunday(selectedDay); 
        await updateWeek();
      }
      else{index--;}
      setState(() {ready = stepGraphReady = true; heartGraphReady = false;});
      await request.getHeartRate(index);
      setState(() {heartGraphReady = true;});
    }

    rightArrow() async{
      if(selectedDay != today){
        selectedDay = DateTime(selectedDay.year,selectedDay.month,selectedDay.day+1);
        if(index == 6){
          index = 0; sunday = setSunday(selectedDay);
          await updateWeek();
        }
        else{index++;}
        setState(() {ready = stepGraphReady = true; heartGraphReady = false;});
        await request.getHeartRate(index);
        setState(() {heartGraphReady = true;});
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} : FitBit analytics'),
        leading: (widget.request != null) ? IconButton(onPressed: () {
          Navigator.pop(context,[sunday,request.sleepPoints]);
        }, icon: const Icon(Icons.arrow_back)) : null,
      ),
      drawer: const NavigationPanel(),
      body: ready ? Column(
        children: [
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: leftArrow, icon: const Icon(Icons.chevron_left, size: 35)),
                InkWell(onTap: calendar, child: SizedBox(height: 60, width: 250, child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('EEEE').format(selectedDay), style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold),),
                      Text(yMd.format(selectedDay), style: dateStyle),
                    ],
                  )),)),
                IconButton(onPressed: rightArrow, icon: const Icon(Icons.chevron_right, size: 35))
              ],),
              SizedBox(height: 5),
            SleepScore(scores[index]),
          ],),
          Expanded(child: (scores[index] != 0) ? ListView(
            children: [ 
              Analysis(
                request.lights[index], 
                request.awakes[index],
                request.asleeps[index],
                request.deeps[index],
                request.rems[index],
                request.steps[index],
                request.sessions[index]),
                Divider(thickness: 2, color: Colors.grey[300],),
              stepGraphReady ? SleepGraph(request.sleepPoints, request.maxs[index], request.mins[index], false) 
              : const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()),),
              tips(request.weekScores[index]),
              heartGraphReady ? heartRateGraph(request.heartData, request.maxs[index], request.mins[index], request.heartMaxY, request.heartMinY, request.heartAvg) 
              : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()),),
            ],) : const SizedBox()),
        ],
      )
         
      : const Center(child: CircularProgressIndicator(),),
    );
  }

  Future<void> updateWeek() async {
    await requestData();
    scores = request.weekScores;
  }
  
  requestData() async {
    if(!await request.tryReadStorage(sunday)){
      setState(() {ready = false;});
      await request.weekSleepData(sunday);
    }
    else{
      setState(() {scores = request.weekScores; stepGraphReady = heartGraphReady = false;});
      await request.stepGraphData(sunday);
    }
  }
  
}