import 'package:flutter/material.dart';

class SleepScore extends StatelessWidget {
  final double score;
  late String sleepQuality = '';
  late Color progressColor = Colors.green;

  SleepScore(this.score) {
    if (score >= 80) {
      sleepQuality = 'Great';
      progressColor = Colors.green;
    } else if (score >= 62) {
      sleepQuality = 'Good';
      progressColor = Colors.yellow;
    } else if (score >= 45) {
      sleepQuality = 'Okay';
      progressColor = Colors.orange;
    } else {
      sleepQuality = 'Bad';
      progressColor = Colors.red;
    }
  }

  ///To check if sleep works
  // String durationToString(int minutes) {
  //   var d = Duration(minutes: minutes);
  //   List<String> parts = d.toString().split(':');
  //   return '${parts[0].padLeft(2, '0')} hr ${parts[1].padLeft(2, '0')} min';
  // }

  // double eval(double steps, double deep, double rem, double session) {
  //   print(
  //       'sesssion(min)---> ${session} deep ${deep} rem ${rem} steps ${steps}');
  //   print(
  //       'sesssion(hour) ---> ${durationToString(session.toInt())} deep ${durationToString(deep.toInt())} rem ${durationToString(rem.toInt())} steps ${steps}');
  //   double score =
  //       (steps * 0.005) + (deep * 0.25) + (rem * 0.25) + (session * 0.05);
  //   print('final => ${score} and percent = ${score / 100}');
  //   return score / 100;
  // }

  void determine() {
    // Determine sleep quality and progress color
    if (score >= 80) {
      sleepQuality = 'Great';
      progressColor = Colors.green;
    } else if (score >= 65) {
      sleepQuality = 'Good';
      progressColor = Colors.yellow;
    } else if (score >= 50) {
      sleepQuality = 'Okay';
      progressColor = Colors.orange;
    } else {
      sleepQuality = 'Bad';
      progressColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      ////Copy n pasted from TipsPage
      color: Colors.deepPurple,
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: (score != 0) ? Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Your Sleep Score:',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 13.0),
          Container(
            //
            width: 100.0,
            height: 100.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120.0, // Size of the circular progress indicator
                  height: 120.0,
                  child: CircularProgressIndicator(
                    value: ((score) / 100), // Dummy sleep score value (85%)
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeWidth: 20.0,
                  ),
                ),
                Text(
                  (score)
                      .toStringAsFixed(0), // Dummy sleep score value
                  style: const TextStyle(
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            sleepQuality, // Display sleep quality
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color:
                  progressColor, // Use the same color as the progress indicator
            ),
          ),
        ],
      ) : const SizedBox(
        height: 183,
        child: Center(
          child: Text("No Sleep Data Found", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}
