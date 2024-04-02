import 'package:flutter/material.dart';

class Analysis extends StatelessWidget {
  final double session;
  final double deep;
  final double rem;
  final double steps;
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

  Widget CircleThingy(double type, String typeString) {
    return 
     Column(
        children: [
          Container(
            //
            width: 50.0,
            height: 50.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 30.0, // Size of the circular progress indicator
                  height: 30.0,
                  child: CircularProgressIndicator(
                    value: (type/session), // Dummy sleep score value (85%)
                    backgroundColor: Colors.white,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 10.0,
                  ),
                ),
                Text(
                  type.toStringAsFixed(1), // Dummy sleep score value
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child: CircleThingy(awake,'awake')
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child: CircleThingy(rem,'rem')
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child:  CircleThingy(light, 'light')
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child:  CircleThingy(deep,'deep')
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child:  CircleThingy(asleep,'asleep')
            ),
             ],
    );
  }
}
