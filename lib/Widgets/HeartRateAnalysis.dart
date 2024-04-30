import 'package:flutter/material.dart';

class HeartRateAnalysis extends StatelessWidget {
  final double avgHeartRate;

  HeartRateAnalysis(
    this.avgHeartRate,
  );

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    var hour = parts[0].padLeft(2, '0');
    var min = parts[1].padLeft(2,'0');
    
    if(hour == '00'){
      return '${int.parse(parts[1])}m';
    } else if (min == '00'){
      return '${int.parse(parts[0])}H';
    } else {
     return '${int.parse(parts[0])}H ${int.parse(parts[1])}m';
    }

  }

    String tooltipText(double minutes){
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).floor();
    return "${hours}H ${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    return Container(); 
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   //crossAxisAlignment: CrossAxisAlignment.start,

    //   children: <Widget>[
    //     Row(children: [
    //       const SizedBox(width: 30),
    //       Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    //         const Text('Total Steps:',
    //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
    //         Text('$steps',
    //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
    //       ]),
    //       const SizedBox(height: 30, width: 30),
    //       Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    //         const Text('Total Sleep Session:',
    //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
    //         Text(durationToString(session.toInt()),
    //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
    //       ]),
    //     ]),
    //     Divider(thickness: 2, color: Colors.grey[300]),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         CircleThingy(awake, 'Awake'),
    //         CircleThingy(rem, 'REM'),
    //         CircleThingy(light, 'Light'),
    //         CircleThingy(deep, 'Deep'),
    //         CircleThingy(asleep, 'Asleep'),
    //       ],
    //     ),
    //   ],
    // );
  }
}

