import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreViewWidget extends StatelessWidget {
  ScoreViewWidget({
    required this.weekScores,
    required this.sunday,
    required this.startTimes,
    required this.endTimes,
    super.key,
  });

  List<double> weekScores;
  DateTime sunday;
  List<DateTime> startTimes;
  List<DateTime> endTimes;

  late final List<Widget> scoreViews = [
    ScoreCard(score: weekScores[0], startTime: startTimes[0], endTime: endTimes[0], title: "Sunday", date: sunday), 
    ScoreCard(score: weekScores[1], startTime: startTimes[1], endTime: endTimes[1], title: "Monday", date: sunday.add(const Duration(days: 1))),
    ScoreCard(score: weekScores[2], startTime: startTimes[2], endTime: endTimes[2], title: "Tuesday", date: sunday.add(const Duration(days: 2))), 
    ScoreCard(score: weekScores[3], startTime: startTimes[3], endTime: endTimes[3], title: "Wednesday", date: sunday.add(const Duration(days: 3))),
    ScoreCard(score: weekScores[4], startTime: startTimes[4], endTime: endTimes[4], title: "Thursday", date: sunday.add(const Duration(days: 4))), 
    ScoreCard(score: weekScores[5], startTime: startTimes[5], endTime: endTimes[5], title: "Friday", date: sunday.add(const Duration(days: 5))),
    ScoreCard(score: weekScores[6], startTime: startTimes[6], endTime: endTimes[6], title: "Saturday", date: sunday.add(const Duration(days: 6))),
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
    required this.score,
    required this.date,
    required this.startTime,
    required this.endTime,
    super.key, 
  });

  final Color lav = const Color.fromARGB(255, 160, 109, 186);

  final DateTime startTime;
  final DateTime endTime;
  final double score;
  final String title;
  final DateTime date;
  final DateFormat Md = DateFormat.Md();
  final DateFormat jm = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    String scoreText;
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
            height: 80, 
            child: InkWell(
              onTap: () { /* ... */ },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                  Container(
                    width: 50,
                    height: 50, 
                    decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle), 
                    child: Center(child: Text(scoreText, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Text("${jm.format(startTime)} - ${jm.format(endTime)}", style: TextStyle(fontSize: 20, ),),
                    ),
                    ]),
              ),
          )),
        ),
      ],
    ) : const SizedBox();
    
  }
}