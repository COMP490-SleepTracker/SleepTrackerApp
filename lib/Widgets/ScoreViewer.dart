import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/HealthStuff/SleepRequest.dart';
import 'package:sleeptrackerapp/Widgets/StepGraph.dart';
import 'package:sleeptrackerapp/Widgets/CardSleepGraph.dart';


typedef OpenStats = void Function(int);

class ScoreViewWidget extends StatelessWidget {
  ScoreViewWidget({
    required this.sunday,
    required this.context,
    required this.request,
    required this.openStats,
    //required this.sleepDisplay,
    super.key,
  });

  final DateTime sunday;
  final OpenStats openStats;
  final BuildContext context;
  final SleepRequest request;
    //List<Widget> sleepDisplay; 


  late final List<Widget> scoreViews = [  //snippet to add sleep chart : sleep: sleepDisplay[0]
    ScoreCard(request: request, title: "Sunday", date: sunday, openStats: openStats, weekday: 0), 
    ScoreCard(request: request, title: "Monday", date: sunday.add(const Duration(days: 1)), openStats: openStats, weekday: 1),
    ScoreCard(request: request, title: "Tuesday", date: sunday.add(const Duration(days: 2)), openStats: openStats, weekday: 2), 
    ScoreCard(request: request, title: "Wednesday", date: sunday.add(const Duration(days: 3)), openStats: openStats, weekday: 3),
    ScoreCard(request: request, title: "Thursday", date: sunday.add(const Duration(days: 4)), openStats: openStats, weekday: 4), 
    ScoreCard(request: request, title: "Friday", date: sunday.add(const Duration(days: 5)), openStats: openStats, weekday: 5),
    ScoreCard(request: request, title: "Saturday", date: sunday.add(const Duration(days: 6)), openStats: openStats, weekday: 6),
    ];


  @override
  Widget build(BuildContext context) {
    return Column(
      children: scoreViews
    );
  }
}

class ScoreCard extends StatelessWidget {

    ScoreCard({
    required this.title,
    required this.date,
    required this.openStats,
    required this.weekday,
    required this.request,
    // required this.sleep,
    super.key, 
  });

  final Color lav = const Color.fromARGB(255, 160, 109, 186);

  final String title;
  final DateTime date;
  final DateFormat Md = DateFormat.Md();
  final DateFormat jm = DateFormat.jm();
    //final Widget sleep; 
  final OpenStats openStats;
  final int weekday;
  final SleepRequest request;
  
  
  @override
  Widget build(BuildContext context) {
    String scoreText;
    double score = request.weekScores[weekday];
      if(score == -1){scoreText = 'NA';}
      else{scoreText = score.round().toString();}
      return ((score != 0) && (!score.isNaN)) ? Column(
      children: [
        Container(color: lav, width: double.infinity,
        child: Padding(padding: const EdgeInsets.only(left: 5),
          child: Text("$title - ${Md.format(date)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,  fontSize: 14),),
        ),),
        Center(
          child: Ink( 
            height: 90, 
            child: InkWell(
              onTap: (){openStats(weekday);},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center, 
                      children: [
                        CircularProgressIndicator(value: score/100, backgroundColor: Colors.black, valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple), strokeWidth: 7.5,), 
                        Text(scoreText, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)],),
                  // Container(
                  //   width: 50,
                  //   height: 50, 
                  //   decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle), 
                  //   child: Center(child: Text(scoreText, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)),
                  //   ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 5),
                       // child: SafeArea(child:  request.sleepCharts[weekday])
                        child:  SafeArea(child: CardSleepGraph(request.sleepPoints, request.maxs[weekday], request.mins[weekday], false))
                      //child: Text("${jm.format(request.startTimes[weekday])} - ${jm.format(request.endTimes[weekday])}", style: TextStyle(fontSize: 20, ),),
                    ),
                    ]),
              ),
          )),
        ),
      ],
    ) : const SizedBox();
    
  }
}
//healthdata