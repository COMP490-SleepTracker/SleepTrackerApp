import 'package:sleeptrackerapp/Widgets/bar_graph/bar_data_week.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraphWeek extends StatelessWidget {
  const BarGraphWeek({super.key, required this.weeklySummary});
  final List weeklySummary;

  @override
  Widget build(BuildContext context) {
    BarDataWeek myBarData = BarDataWeek(
        sunAmount: weeklySummary[0],
        monAmount: weeklySummary[1],
        tueAmount: weeklySummary[2],
        wedAmount: weeklySummary[3],
        thuAmount: weeklySummary[4],
        friAmount: weeklySummary[5],
        satAmount: weeklySummary[6]);

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
                    colors: [ Color.fromARGB(163, 40, 40, 40),Colors.deepPurple, Colors.deepPurpleAccent, ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter
                    ),
                  width: 35,
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
              const TextStyle(fontSize: 12,color: Colors.white));
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
    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12);

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Sun', style: style);
        break;
      case 1:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Tue', style: style);
        break;
      case 3:
        text = const Text('Wed', style: style);
        break;
      case 4:
        text = const Text('Thu', style: style);
        break;
      case 5:
        text = const Text('Fri', style: style);
        break;
      case 6:
        text = const Text('Sat', style: style);
        break;
      default:
        text = const Text('', style: style);
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }
}
