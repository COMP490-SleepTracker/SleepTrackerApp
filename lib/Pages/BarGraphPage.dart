import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_week.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_month.dart';
import 'package:sleeptrackerapp/Widgets/SleepDebt.dart';
import 'package:sleeptrackerapp/HealthStuff/SleepRequest.dart';
import 'package:sleeptrackerapp/Widgets/ScoreViewer.dart';
import 'package:collection/collection.dart';

import 'Statistics/StatsPage.dart';

typedef OpenStats = void Function(int);



class BarGraphPage extends StatefulWidget{
  const BarGraphPage({super.key, required this.title});
  final String title;

  @override
  State<BarGraphPage> createState() => BarGraphPageState();
}

class BarGraphPageState extends State<BarGraphPage>{
  late DateTime today = setSunday(DateTime.now());
  late DateTime selectedDay = setSunday(DateTime.now());

  DateFormat df = DateFormat.Md();
  late String weekLabel = "${df.format(selectedDay)} - ${df.format(selectedDay.add(const Duration(days: 6)))}";

  SleepRequest request = SleepRequest();

  List<double> weeklyHours = [0,0,0,0,0,0,0];
  List<double> monthlySummary = [0,0,0,0,0];
  List<double> scoresWeek = [0,0,0,0,0,0,0];
  List<DateTime> startTimes = List.filled(7, DateTime(0));
  List<DateTime> endTimes = List.filled(7, DateTime(0));

  double avgScore = 0;
  double avgSlept = 0.0;
  double sleepDebt = 0.0;
  double sleepDebtTemp = 0.0;
  
  bool stepsReady = false;
  bool weekEnabled = true;
  bool monthEnabled = false; 
  bool durationsEnabled = true;
  bool ready = false;

  TextStyle tabs = const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.w600);
  TextStyle tabs2 = const TextStyle(color: Colors.grey,fontSize: 16,);
  BoxDecoration bottomBorder = const BoxDecoration(border: BorderDirectional(bottom: BorderSide(width: 2.5, color: Colors.deepPurpleAccent)));

  @override
  void initState(){
    // SecureStorage().deleteAll();
    request.setSleepDebt();
    setChartWeek();
    super.initState();
  }

    @override
  void dispose() {
    super.dispose();
  }

  ///Returns the [DateTime] object of midnight on Sunday of the calendar week of [selectedDay]
  DateTime setSunday(DateTime selectedDay) {
    int day = selectedDay.weekday; //Day of the week (Mon = 1, Tue = 2, ...)
    
    DateTime sunday = selectedDay.subtract(Duration(days: day));
    sunday = DateTime(sunday.year,sunday.month,sunday.day);
    return sunday;
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
                 Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(onTap: weekEnabled ? null : timeScaleChange, 
                      child: Container(decoration: weekEnabled ? bottomBorder : null, 
                        height: 50, width: 205, child: Center(child: Text("Week", style: weekEnabled ? tabs : tabs2)))),
                      InkWell(onTap: weekEnabled ? timeScaleChange :null, 
                      child: Container(decoration: weekEnabled ? null : bottomBorder,
                        height: 50, width: 205, child: Center(child: Text("Month",style: weekEnabled ? tabs2 : tabs)))),
                    ]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    weekEnabled ? IconButton(onPressed: leftArrow, icon: const Icon(Icons.chevron_left, size: 35,),) : const SizedBox(height: 48,),
                    Text(weekEnabled ? weekLabel : "Weekly Sleep Average", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
                    weekEnabled ? IconButton(onPressed: selectedDay != today ? rightArrow : null, icon: const Icon(Icons.chevron_right, size: 35,)) 
                    : const SizedBox()
                  ]),
                Text("Average: ${durationsEnabled ? tooltipText(avgSlept) : avgScore.toInt()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                displayBars(),
                
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  ElevatedButton(onPressed: durationsEnabled ? null : barTypeChange, 
                  style: durationsEnabled ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.deepPurpleAccent)): null, child: const Text("Durations", style: TextStyle(color: Colors.white),)),
                  ElevatedButton(onPressed: durationsEnabled ? barTypeChange : null, style: !durationsEnabled ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.indigo)): null,
                  child: const Text("Scores",style: TextStyle(color: Colors.white),)),
                  ],),
                const Divider(),
                SizedBox( width: 300,height: 100, 
                  child: SleepDebt(weeklyHours: weeklyHours, sleepDebtTemp: sleepDebtTemp),
                ), //snippet for sleep chart in score: sleepDisplay: sleepChart
                (weekEnabled && ready) ? ScoreViewWidget(openStats: openStats,context: context, sunday: selectedDay, request: request, stepsReady: stepsReady) 
                : const SizedBox()
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
      child: Stack(children: [
        weekEnabled ? BarGraphWeek(weeklySummary: durationsEnabled ? weeklyHours : scoresWeek, durationsEnabled: durationsEnabled,) : 
        BarGraphMonth(monthlySummary: monthlySummary, durationsEnabled: durationsEnabled,),
        Align(alignment: Alignment.center,child: ready ? null: const CircularProgressIndicator())],)
    );
  }

  ///Toggles 1 Week Graph and 5 Week Graph
  void timeScaleChange() {
    weekEnabled = !weekEnabled;
    monthEnabled = !monthEnabled;
    if(weekEnabled){setChartWeek();}
    else{setChartMonth();}
  }

  void barTypeChange(){
    durationsEnabled = !durationsEnabled;
    if(monthEnabled){setChartMonth();}
    else{setState(() {});}
  }

  ///Retrieves Health Connect data for specified week if it is not already in storage
  void setChartWeek() async {
    setState(() {stepsReady = false;});
    weekLabel = "${df.format(selectedDay)} - ${df.format(selectedDay.add(const Duration(days: 6)))}";
    if(!await request.tryReadStorage(selectedDay)){
      setState(() {ready = false; weeklyHours = [0,0,0,0,0,0,0]; scoresWeek = [0,0,0,0,0,0,0]; avgSlept = 0;});
      await request.weekSleepData(selectedDay);
    }else{
      setValues();
      await request.stepGraphData(selectedDay);
      }
    setValues();
    if(!durationsEnabled){
      int days = 0; 
      for(var x in scoresWeek){if(x>0)days++;}
      if (days == 0) {avgScore = 0;}
      else{avgScore = scoresWeek.sum / days;}}
    setState(() {
      stepsReady = true;
    });
  }

  void setValues() {
    weeklyHours = request.weekHours;
    scoresWeek = request.weekScores;
    avgSlept = request.weekAvg;
    startTimes = request.startTimes;
    endTimes = request.endTimes;
    sleepDebtTemp = request.sleepDebtTemp;
    setState(() {ready = true;});
  }

  ///Retrieves Health Connect data for last 5 weeks if they are not already in storage
  void setChartMonth() async {
    // setState(() {monthlySummary = [0,0,0,0,0,0,0];});
    DateTime curr = today;
    for(int i = 4; i >= 0; i-- ){
      if (!await request.tryReadStorage(curr)){
        setState(() {ready = false;});
        await request.weekSleepData(curr);
      }
      if(durationsEnabled){monthlySummary[i] = request.weekAvg;}
      else{int days = 0;
        for (var element in request.weekScores) {if(element != 0) days++;}
        if(days == 0) continue;
        monthlySummary[i] = request.weekScores.sum / days;}
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
      if(durationsEnabled) {avgSlept = total/daysRecorded;}
      else{avgScore = total/daysRecorded;}
    }
    ready = true;
  });
  }

  String tooltipText(double minutes){
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).floor();
    return "${hours}H ${mins}m";
  }

  ///selected week moves backwards 1 week
  void leftArrow() {
    selectedDay = selectedDay.subtract(const Duration(days: 7));
    setState(() {setChartWeek();});
  }

  ///selected week moves forward 1 week
  void rightArrow() {
    selectedDay = selectedDay.add(const Duration(days: 7));
    setState(() {setChartWeek();});
  }

    Future<void> openStats(int weekday) async {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => 
      tempStatsPage(
        title: "Statistics",
        sunday: selectedDay,
        weekday: weekday,
        request: request,
        )));

        if(!context.mounted) {
          return;
        } else if(result != selectedDay) {
          setState(() {selectedDay = result[0]; setChartWeek(); request.sleepPoints = result[1];});
        }
    }
}