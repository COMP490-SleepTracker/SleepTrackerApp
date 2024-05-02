import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_data_month.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraphMonth extends StatelessWidget {
  const BarGraphMonth({super.key, required this.monthlySummary, required this.durationsEnabled});
  final List monthlySummary;
  final bool durationsEnabled;

  @override
  Widget build(BuildContext context) {
    BarDataMonth myBarData = BarDataMonth(
        week1: durationsEnabled ? monthlySummary[0] / 60 : monthlySummary[0],
        week2: durationsEnabled ? monthlySummary[1] / 60 : monthlySummary[1],
        week3: durationsEnabled ? monthlySummary[2] / 60 : monthlySummary[2],
        week4: durationsEnabled ? monthlySummary[3] / 60 : monthlySummary[3],
        week5: durationsEnabled ? monthlySummary[4] / 60 : monthlySummary[4]);


Gradient pinkGradient = const LinearGradient(colors: [
      Color.fromARGB(163, 40, 40, 40),
      Color.fromARGB(255, 105, 70, 128),
      Color.fromARGB(255, 179, 121, 249),
    ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

Gradient blueGradient = const LinearGradient(colors: [
      Color.fromARGB(163, 40, 40, 40),
      Colors.blueAccent,
      Colors.blue,
    ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

    myBarData.initializeBarData();
    return BarChart(BarChartData(
      maxY: durationsEnabled ? 10 : 100,
      minY: 0,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true, getTitlesWidget: getBottomTitles))),
      barGroups: myBarData.barData
          .map((data) => BarChartGroupData(x: data.x, barRods: [
                BarChartRodData(
                  toY: data.y,
                  
                  gradient: durationsEnabled ? pinkGradient : blueGradient,
                  width: 52,
                  borderRadius: BorderRadius.circular(4),
                )
              ]))
          .toList(),
      barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 20,
        tooltipPadding: const EdgeInsets.only(right: 10, left: 10, top: 4),
        tooltipMargin: 20,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
              durationsEnabled ? tooltipText(myBarData.barData[groupIndex].y) : myBarData.barData[groupIndex].y.toInt().toString(),
              textAlign: TextAlign.center,
              const TextStyle(fontSize: 16, color: Colors.white));
        },
      )),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        horizontalLines: [
          HorizontalLine(y: durationsEnabled ? 8: 80, color: const Color.fromARGB(255, 106, 106, 106), strokeWidth: 1.2, dashArray: [10,5])
        ]
        )
    ));
  }

  String tooltipText(double hours){
    if(hours == 0) return "0H 0m";
    String hourText = hours.floor().toString();
    double mins = hours % hours.floor();
    String minsText = (60 * mins).floor().toString();
    return "${hourText}H ${minsText}m";
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    DateTime today = setSunday(DateTime.now().toUtc());
    DateFormat df = DateFormat.Md();

    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(df.format(today.subtract(const Duration(days: 28))), style: style);
        break;
      case 1:
        text = Text(df.format(today.subtract(const Duration(days: 21))), style: style);
        break;
      case 2:
        text = Text(df.format(today.subtract(const Duration(days: 14))), style: style);
        break;
      case 3:
        text = Text(df.format(today.subtract(const Duration(days: 7))), style: style);
        break;
      case 4:
        text = Text(df.format(today), style: style);
        break;
      default:
        text = const Text('', style: style);
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

    DateTime setSunday(DateTime currentDay) {
    int day = currentDay.weekday; //Day of the week (Mon = 1, Tue = 2, ...)
    
    DateTime sunday = day < 7 ? 
    currentDay.subtract(Duration(
      days: day, 
      hours: currentDay.hour, 
      minutes: currentDay.minute, 
      seconds: currentDay.second,
      milliseconds: currentDay.millisecond, 
      microseconds: currentDay.microsecond)) : //Midnight of first calendar day(Sunday) of current week
    currentDay.subtract(Duration(
      days: 7, 
      hours: currentDay.hour, 
      minutes: currentDay.minute, 
      seconds: currentDay.second,
      milliseconds: currentDay.millisecond, 
      microseconds: currentDay.microsecond)); //current day is already sunday, show previous week
    
    if(currentDay == sunday){
      sunday = sunday.subtract(const Duration(days: 7));
    }
    return sunday;
  }
}
