import 'package:intl/intl.dart';
import 'package:sleeptrackerapp/Widgets/bar_graph/bar_data_month.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraphMonth extends StatelessWidget {
  const BarGraphMonth({super.key, required this.monthlySummary});
  final List monthlySummary;

  @override
  Widget build(BuildContext context) {
    BarDataMonth myBarData = BarDataMonth(
        week1: monthlySummary[0] / 60,
        week2: monthlySummary[1] / 60,
        week3: monthlySummary[2] / 60,
        week4: monthlySummary[3] / 60,
        week5: monthlySummary[4] / 60);

    myBarData.initializeBarData();
    return BarChart(BarChartData(
      maxY: 10,
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
                  
                  gradient: const LinearGradient(
                    colors: [ Color.fromARGB(163, 40, 40, 40),Color.fromARGB(255, 105, 70, 128), Color.fromARGB(255, 179, 121, 249), ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter
                    ),
                  width: 52,
                  borderRadius: BorderRadius.circular(4),
                )
              ]))
          .toList(),
      barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 20,
        tooltipPadding: const EdgeInsets.only(right: 5, left: 5, top: 4),
        tooltipMargin: 20,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
              tooltipText(myBarData.barData[groupIndex].y),
              textAlign: TextAlign.center,
              const TextStyle(color: Colors.white));
        },
      )),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        horizontalLines: [
          HorizontalLine(y: 8, color: const Color.fromARGB(255, 106, 106, 106), strokeWidth: 1.2, dashArray: [10,5])
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
