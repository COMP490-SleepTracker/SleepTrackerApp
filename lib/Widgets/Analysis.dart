import 'package:flutter/material.dart';

class Analysis extends StatelessWidget {
  final double session;
  final double deep;
  final double rem;
  final double steps;
  final double awake;
  final double asleep;
  final double light;
  final double Steps;

  Analysis(
    this.light,
    this.awake,
    this.asleep,
    this.deep,
    this.rem,
    this.steps,
    this.session,
    this.Steps,
  );

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    var hour = parts[0].padLeft(2, '0');
    var min = parts[1].padLeft(2,'0');
    
    if(hour == '00'){
      return '${int.parse(parts[1])} min';
    } else if (min == '00'){
      return '${int.parse(parts[0])}} hr';
    } else {
     return '${int.parse(parts[0])} hr ${int.parse(parts[1])} min';
    }
  }

  Widget CircleThingy(double type, String typeString) {
    if (type != 0) {
      //print('$typeString = $type   === ${durationToString(type.toInt())}');
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 2.0),
                child: Row(children: [
                  Column(
                    children: [
                      Container(
                        width: 50.0,
                        height: 40.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width:
                                  40.0, // Size of the circular progress indicator
                              height: 40.0,
                              child: CircularProgressIndicator(
                                value: (type /
                                    session), // Dummy sleep score value (85%)
                                backgroundColor: Colors.black,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                                strokeWidth: 15.0,
                              ),
                            ),
                            Text(
                              ((type / session) * 100).toStringAsFixed(1) +
                                  '%', // Dummy sleep score value
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(typeString,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text(
                      'You spent a total of ${durationToString(type.toInt())} in $typeString')
                ])),
            Container(
                width: 300,
                child: Divider(thickness: 0.5, color: Colors.grey[300])),
          ]);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.start,

      children: <Widget>[
        Row(children: [
          const SizedBox(width: 30),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Total Steps:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('$Steps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]),
          const SizedBox(height: 30, width: 30),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Total Sleep Session:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('${durationToString(session.toInt())}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]),
        ]),
        Divider(thickness: 2, color: Colors.grey[300]),
        CircleThingy(awake, 'awake'),
        CircleThingy(rem, 'rem'),
        CircleThingy(light, 'light'),
        CircleThingy(deep, 'deep'),
        CircleThingy(asleep, 'asleep'),
      ],
    );
  }
}


///Clean this page up 
