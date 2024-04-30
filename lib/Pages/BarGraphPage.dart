import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_week.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_graph_month.dart';
import 'package:sleeptrackerapp/Widgets/SleepDebt.dart';
import 'package:sleeptrackerapp/HealthStuff/SleepRequest.dart';
import 'package:sleeptrackerapp/Widgets/ScoreViewer.dart';

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

  double avgSlept = 0.0;
  double sleepDebt = 0.0;
  double sleepDebtTemp = 0.0;
  
  bool stepsReady = false;
  bool weekEnabled = true;
  bool monthEnabled = false; 
  bool ready = false;

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
                  weekEnabled ? IconButton(onPressed: selectedDay != today ? rightArrow : null, icon: const Icon(Icons.chevron_right)) 
                  : const SizedBox()
              ],),
                Text("Average: ${tooltipText(avgSlept)}"),
                displayBars(),
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
        weekEnabled ? BarGraphWeek(weeklySummary: weeklyHours) : 
        BarGraphMonth(monthlySummary: monthlySummary),
        Align(alignment: Alignment.center,child: ready ? null: const CircularProgressIndicator())],)
    );
  }

  ///Toggles 1 Week Graph and 5 Week Graph
  void buttonChange() {
    weekEnabled = !weekEnabled;
    monthEnabled = !monthEnabled;
    if(weekEnabled){setChartWeek();}
    else{setChartMonth();}
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
    setState(() {});
    DateTime curr = today;
    for(int i = 4; i >= 0; i-- ){
      if (!await request.tryReadStorage(curr)){
        setState(() {ready = false;});
        await request.weekSleepData(curr);
      }
      monthlySummary[i] = request.weekAvg;
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
    if(daysRecorded > 0) {avgSlept = total/daysRecorded;}
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