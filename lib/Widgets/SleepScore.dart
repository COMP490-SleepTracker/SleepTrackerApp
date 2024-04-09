import 'package:flutter/material.dart';

class SleepScore extends StatelessWidget {

  final double score; 

  SleepScore(this.score);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      ////Copy n pasted from TipsPage
      color: Colors.deepPurple,
      padding: const EdgeInsets.only(top: 30, bottom: 50, right: 100, left: 100),
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
                    value: (score) / 110, // Dummy sleep score value (85%)
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 20.0,
                  ),
                ),
                Text(
                     ((score / 110) * 100).toStringAsFixed(1), // Dummy sleep score value
                  style: TextStyle(
                    fontSize: 38.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
