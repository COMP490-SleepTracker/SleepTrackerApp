import 'package:flutter/material.dart';

class Analysis extends StatelessWidget {
  final double session;
  final double deep;
  final double rem;
  final int steps;
  final double awake;
  final double asleep;
  final double light;

  Analysis(
    this.light,
    this.awake,
    this.asleep,
    this.deep,
    this.rem,
    this.steps,
    this.session,
  );

  String durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    var hour = parts[0].padLeft(2, '0');
    var min = parts[1].padLeft(2, '0');

    if (hour == '00') {
      return '${int.parse(parts[1])}m';
    } else if (min == '00') {
      return '${int.parse(parts[0])}H';
    } else {
      return '${int.parse(parts[0])}H ${int.parse(parts[1])}m';
    }
  }

  String tooltipText(double minutes) {
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).floor();
    return "${hours}H ${mins}m";
  }

  String sleepTextDescription(typeString){
    String text = ''; 
    switch(typeString){
      case 'Awake':
        text = 'The Awake state where you are fully alert and conscious.You can respond to your surroundings and react to stimuli.';
        break; 
      case 'REM':
        text = "REM is where most dreams happen. Body becomes immobilized and eyes move rapidly during this stage. Brain activity is very active";
       break; 
      case 'Light':
         text = 'Light state is a deep state of sleep where your brain waves begin to slow down and body temp lowers. This stage accounts for most of your sleep.';
       break; 
      case 'Deep':
        text = 'Deep state is the deepest stage of sleep. Brain waves are slow but strong. It is hard to wake someone at this stage of sleep.';
        break; 
      case 'Asleep':
        text ='Asleep state encompasses the entire sleep process. It contains all types of user sleep during this stage.';
        break;      
    }
    return text;

  }

  Widget CircleThingy(double type, String typeString) {
    if (type != 0) {
      //print('$typeString = $type   === ${durationToString(type.toInt())}');
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 2.0),
                child: 
                  Tooltip(
                showDuration: Duration(seconds: 10),
                triggerMode: TooltipTriggerMode.tap,
                decoration: BoxDecoration(color: Color.fromARGB(255, 62, 62, 62), borderRadius: BorderRadius.all(Radius.circular(5))),
                verticalOffset: 45,
                richMessage: TextSpan(text: sleepTextDescription(typeString), style: TextStyle(color: Colors.white)),
                    
                  child: 
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
                              style: const TextStyle(
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(durationToString(type.toInt()))
                      //  Text(tooltipText(type))
                    ],
                  ),
                  // const SizedBox(width: 10),
                  // Text(
                  //     'You spent a total of ${durationToString(type.toInt())} in $typeString')
                )),
            // Container(
            //     width: 300,
            //     child: Divider(thickness: 0.5, color: Colors.grey[300])),
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
            const Text('Total Steps:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('$steps',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]),
          const SizedBox(height: 30, width: 30),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Total Sleep Session:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(durationToString(session.toInt()),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
          ]),
        ]),
        Divider(thickness: 2, color: Colors.grey[300]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleThingy(awake, 'Awake'),
            CircleThingy(rem, 'REM'),
            CircleThingy(light, 'Light'),
            CircleThingy(deep, 'Deep'),
            CircleThingy(asleep, 'Asleep'),
          ],
        ),
      ],
    );
  }
}


///Clean this page up 
