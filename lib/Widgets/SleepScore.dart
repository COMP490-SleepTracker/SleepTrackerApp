import 'package:flutter/material.dart';

class SleepScore extends StatelessWidget {
  final double score;
  late String sleepQuality = '';
  late Color progressColor = Colors.green;

  SleepScore(this.score) {
    if (score >= 89) {
      sleepQuality = 'Great';
      progressColor = Colors.green;
    } else if (score >= 68) {
      sleepQuality = 'Good';
      progressColor = Colors.yellow;
    } else if (score >= 47) {
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
    if (score >= 89) {
      sleepQuality = 'Great';
      progressColor = Colors.green;
    } else if (score >= 68) {
      sleepQuality = 'Good';
      progressColor = Colors.yellow;
    } else if (score >= 47) {
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
      ////Copy n pasted from TipsPage
      decoration: BoxDecoration(
        gradient: const LinearGradient(
               colors: [Color.fromARGB(224, 167, 224, 233), Color.fromARGB(255, 225, 139, 241)],  
              begin: Alignment.bottomLeft, 
               end: Alignment.topRight,
          ),  
        ),
     // color: Colors.deepPurple,
     //color: Color.fromARGB(255, 198, 119, 212),
      padding:
          const EdgeInsets.only(top: 30, bottom: 50, right: 100, left: 100),
      child: Column(
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
                    value: ((score) / 110), // Dummy sleep score value (85%)
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeWidth: 20.0,
                  ),
                ),
                Text(
                  ((score / 110) * 100)
                      .toStringAsFixed(0), // Dummy sleep score value
                  style: TextStyle(
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
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
      ),
    );
  }
}
