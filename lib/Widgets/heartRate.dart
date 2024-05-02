import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';

class heartRateGraph extends StatelessWidget {
  final List<HealthDataPoint>? heartRateData;
  final double maxX;
  final double minX;
  final double minY;
  final double maxY;
  final double avgHeartRate;
  final DateFormat jm = DateFormat.jm();

  heartRateGraph(this.heartRateData, this.maxX, this.minX, this.maxY, this.minY,
      this.avgHeartRate);

  final double padding = 10.0;
  final List<FlSpot> dataPoints = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text('Your HeartRate: ${avgHeartRate.toStringAsFixed(1)} Beats per Min',
            style: const TextStyle(
              //  color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              // letterSpacing: 2,
            ),
            textAlign: TextAlign.center),
        AspectRatio(
          aspectRatio: 1.7, //1.30 width : height  2.3
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24, //25
              left: 24, //12 6
              top: 30, //24  10
              bottom: 12, //12
            ),
            child: main(),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateDataPoints() {
    for (var heartRate in heartRateData!) {
      dataPoints.add(FlSpot(
          heartRate.dateFrom.millisecondsSinceEpoch.toDouble(),
          double.parse(heartRate.value.toString()).toDouble()));
    }
    return dataPoints;
  }

  LineChart main() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipItems:(touchedSpots) {
           List<LineTooltipItem> names =List.empty(growable: true);
          for (var element in touchedSpots) {names.add(LineTooltipItem("${element.y.ceil()} bpm\n${jm.format(DateTime.fromMillisecondsSinceEpoch(element.x.toInt()))}", const TextStyle(fontSize: 12))); }
          return names;
        },  )),
        minX: minX.toDouble(), // minX.toDouble()
        maxX: maxX.toDouble(),
        minY: minY,
        maxY: maxY,
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 18, //30
              // getTitlesWidget:
              // (value,meta) {
              //   const style = TextStyle(fontWeight: FontWeight.bold);
              //   if(value == minX){
              //     return Text(DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(minX.toInt())), style: style);
              //   } else if (value == maxX){
              //      return
              //      Container(padding: const EdgeInsets.only(right: 25),child:
              //       Text(DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(maxX.toInt())), style:style));
              //   } else {
              //     return Container();
              //   }
              // }
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 1,
              //  getTitlesWidget: (value, meta) => asleepSession == true ?  leftTitleAsleep(value, meta):leftTitleWidgets(value, meta),
              reservedSize: 37,

              ///42
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: _generateDataPoints(),
            isStepLineChart: false,
            isCurved: true,
            curveSmoothness: 0.030,
            color: Colors.red,
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
