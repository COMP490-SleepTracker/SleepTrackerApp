import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class SleepGraph extends StatelessWidget {
  final List<HealthDataPoint>? sleepData;
  final double maxX;
  final double minX;

  SleepGraph(this.sleepData, this.maxX, this.minX);

  final double padding = 10.0;

  int SleepTypeToInt(String type) {
    switch (type) {
      case "SLEEP_AWAKE":
        return 5;
      case "SLEEP_LIGHT":
        return 3;
      case "SLEEP_REM":
        return 4;
      case "SLEEP_DEEP":
        return 2;
      // case "SLEEP_ASLEEP":
      //   return 1;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        //main();

        Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.30,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 25,
              left: 6, //12
              top: 10, //24
              bottom: 12, //12
            ),
            child: main(),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateDataPoints() {
    List<FlSpot> dataPoints = [];

    print('=============== min X ${minX}==and  maxX ${maxX}======================================');
        print('====MINX====${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(minX.toInt()))}}');
                 final middle =  (minX + maxX) / 2;
                print('====MaxX====${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(maxX.toInt()))}}');
         

  print('-----Middle---- ${middle} CONVERTED ===> ${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(middle.toInt()))}');

    for (var sleepSession in sleepData!) {
      //print('${sleepSession.dateFrom.minute} & ${sleepSession.typeString}');
      //print('type ${sleepSession.typeString} and ${SleepTypeToInt(sleepSession.typeString).toDouble()} ');
      if (sleepSession.typeString != "SLEEP_SESSION") {
        dataPoints.add(FlSpot(
            sleepSession.dateFrom.millisecondsSinceEpoch.toDouble(),
            SleepTypeToInt(sleepSession.typeString).toDouble()));
        dataPoints.add(FlSpot(
            sleepSession.dateTo.millisecondsSinceEpoch.toDouble(),
            SleepTypeToInt(sleepSession.typeString).toDouble()));
        print(
            '${sleepSession.dateFrom.millisecondsSinceEpoch.toDouble()} and ${SleepTypeToInt(sleepSession.typeString).toDouble()}');
      } else {
        print('Sleep Session ----> ${sleepSession.value} ==> ( ${sleepSession.dateFrom} - ${sleepSession.dateTo} ))'); 
      }
    }
    return dataPoints;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 6,
    );
    String text;
    switch (value.toInt()) {
      case 5:
        text = 'Awake';
        break;
      case 4:
        text = 'Rem';
        break;
      case 3:
        text = 'Light';
        break;
      case 2:
        text = 'Deep';
        // case 1:
        //   text = 'Asleep';
        break;

      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
     final style = TextStyle(
      color: Colors.blueGrey,
      fontWeight: FontWeight.bold,
      fontSize: 6,
    );
    final start = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(minX.toInt())); 
    final end = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(maxX.toInt())); 
    // final middle =  (start + end) / 2; 

    if (value == minX){
      print('yess works');
      return Text('${start}',style: style,);
    } else if(value == maxX){
      return Text('${end}',style: style,);
    }
    else return Container();

    // print('${value} --> ${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000))} ');
    // return Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000)),style: style,);
  }

  LineChart main() {
    return LineChart(
      LineChartData(
        minX: minX.toDouble(), // minX.toDouble()
        maxX: maxX.toDouble(),
        minY: 2,
        maxY: 5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: false, // this one
        ),
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 30, //30
              interval: 1,        
             // getTitlesWidget: (values, meta) => bottomTitleWidgets(values,meta)
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta),
              //reservedSize: 45, ///42
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: _generateDataPoints(),
            // color: spots.map((spot) => getColorForY(spot.y)).toList(),
            isStepLineChart: false,
            isCurved: true,
            curveSmoothness: 0.079,
            color: Colors.green,
            belowBarData: BarAreaData(
              show: false,
            ),
            barWidth: 1,
            dotData: const FlDotData(
              show: false,
            ),
          ),
        ],
      ),
    );
  }
}
