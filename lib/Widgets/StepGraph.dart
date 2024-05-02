import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class SleepGraph extends StatelessWidget {
  final List<HealthDataPoint>? sleepData;
  final double maxX;
  final double minX;
  final bool asleepSession;
  final DateFormat jm = DateFormat.jm();
  String typeLabel="TYPE";
  String timeLabel="TIME-TIME";

  SleepGraph(this.sleepData, this.maxX, this.minX, this.asleepSession);

  final double padding = 10.0;
  final List<FlSpot> dataPoints = [];

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
      case "SLEEP_ASLEEP":
        return 2;
      default:
        return -1;
    }
  }

  String intToSleepType(int x){
    switch(x){
      case 5 : return "Awake";
      case 4 : return "REM";
      case 3 : return "Light";
      case 2 : return "Deep";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Text('  Your Sleep Session',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        AspectRatio(
          aspectRatio: 1.3, //1.30 width : height  2.3
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24, //25
              left: 6, //12 6
               //24  10
              bottom: 30, //12
            ),
            child: main(),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateDataPoints() {
    for (var sleepSession in sleepData!) {
      if (sleepSession.typeString != "SLEEP_SESSION" && 
      sleepSession.dateFrom.millisecondsSinceEpoch >=minX && 
      sleepSession.dateTo.millisecondsSinceEpoch <= maxX) {
        dataPoints.add(FlSpot(
            sleepSession.dateFrom.millisecondsSinceEpoch.toDouble(),
            SleepTypeToInt(sleepSession.typeString).toDouble()));
        dataPoints.add(FlSpot(
            sleepSession.dateTo.millisecondsSinceEpoch.toDouble(),
            SleepTypeToInt(sleepSession.typeString).toDouble()));
      }
    }
    return dataPoints;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10, //6
    );
    String text;
    switch (value.toInt()) {
      case 5:
        text = 'Awake';
        break;
      case 4:
        text = 'REM';
        break;
      case 3:
        text = 'Light';
        break;
      case 2:
        text = 'Deep';
        break;

      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget leftTitleAsleep(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10, //6
    );
    String text;
    switch (value.toInt()) {
      case 5:
        text = 'Awake';
        break;
      case 2:
        text = 'Asleep';
        break;

      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChart main() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipItems: (touchedSpots) {
          List<LineTooltipItem> names =List.empty(growable: true);
          for (var element in touchedSpots) {names.add(LineTooltipItem("${intToSleepType(element.y.toInt())}\n${jm.format(DateTime.fromMillisecondsSinceEpoch(element.x.toInt()))}", const TextStyle(fontSize: 12))); }
          return names;
        },)),
        minX: minX.toDouble(), // minX.toDouble()
        maxX: maxX.toDouble(),
        minY: 1.8, //2  1.5
        maxY: 6,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true, // this one
          getDrawingHorizontalLine: (value) {
            if (value == 2 || value == 3 || value == 4 || value == 5) {
              return const FlLine(
                color: Colors.grey,
                strokeWidth: 1,
              );
            } else {
              return const FlLine(
                color: Colors.transparent,
                strokeWidth: 0,
              );
            }
          },
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
                showTitles: true,
                reservedSize: 18, //30
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontWeight: FontWeight.bold);
                  if (value == minX) {
                    return Text(
                        jm.format(
                            DateTime.fromMillisecondsSinceEpoch(minX.toInt())),
                        style: style);
                  } else if (value == maxX) {
                    return Container(
                        padding: const EdgeInsets.only(right: 25),
                        child: Text(
                            jm.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    maxX.toInt())),
                            style: style));
                  } else {
                    return Container();
                  }
                }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => asleepSession == true
                  ? leftTitleAsleep(value, meta)
                  : leftTitleWidgets(value, meta),
              reservedSize: 37,

              ///42
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            lineChartStepData: const LineChartStepData(stepDirection: 0.1),
            spots: _generateDataPoints(),
            isStepLineChart: false,
            isCurved: true,
            curveSmoothness: 0.030,
            color: Colors.blue,
            belowBarData: BarAreaData(
              show: true,
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
