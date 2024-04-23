import 'package:flutter/cupertino.dart';

class SleepDebt extends StatefulWidget{
  const SleepDebt({super.key,
  required this.weeklyHours,
  required this.sleepDebtTemp
  });
  final List<double> weeklyHours;
  final double sleepDebtTemp;

  @override
  State<SleepDebt> createState() => SleepDebtState();
}

  String tooltipText(double minutes){
    int hours, mins;
    if(minutes > 0){
      hours = (minutes / 60).floor();
      mins = (minutes % 60).floor();
      }
    else{
      hours = (minutes / 60).ceil();
      mins = (-1*minutes % 60).floor();
      if(hours == 0){mins*=-1;}
    }
    return "${hours}H ${mins}m";
  }

class SleepDebtState extends State<SleepDebt>{
    double setWeekDebt(){
    int daysRecorded = 0;
    double total = 0;
    for(int i = 0; i < widget.weeklyHours.length; i++){
      if(widget.weeklyHours[i] != 0){
        total+= widget.weeklyHours[i];
        daysRecorded++;
      }
    }
    if(total == 0) return 0;
    return ((daysRecorded*8*60) - (total));
  }

  @override
  Widget build(BuildContext context) {
      return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              const Text("Sleep Debt", style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    Text("Total:",style: TextStyle(fontSize: 20),),
                    Text("This Week:",style: TextStyle(fontSize: 20),),
                    ],),
                    const SizedBox(width: 100,),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(tooltipText(widget.sleepDebtTemp),style: const TextStyle(fontSize: 20)),
                    Text(tooltipText(setWeekDebt()),style: const TextStyle(fontSize: 20)),
                    ],),
                ],
              ),
          ],);
  } 
}