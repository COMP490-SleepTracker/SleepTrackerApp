// class HealthConnectGraph {
 
// }


import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.red,
    Colors.blue,
  ];

  bool showAvg = false;


//setup for chart 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 10, //12
              top: 10, //24
              bottom: 10, //12
            ),
            child: LineChart(
               mainData(),
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////////////////////////////////////////


  ///X - AXIS 
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  ///Y-Axis
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 6,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Sleep Awake';
        break;
      case 3:
        text = 'Sleep Light';
        break;
      case 5:
        text = 'Sleep REM';
        break;
       case 6:
        text = 'SLEEP DEEP';
        break;
        
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  ///THIS IS THE GRAPH ITSELF, USES x and y axis tiles 
  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.pink,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.yellow,
            strokeWidth: 1,
          );
        },
      ),

      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, //30 
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 45, ///42
          ),
        ),
      ),

      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11, //11
      minY: 0,
      maxY: 6,  //6
      lineBarsData: [
        LineChartBarData(
          spots: const [
            // FlSpot(0, 3),
            // FlSpot(3, 6),
            // FlSpot(6, 9),
            // FlSpot(9,14),
            // FlSpot(14, 16),
            // FlSpot(16, 19),
            // FlSpot(19, 24),
           // FlSpot((DateTime.now()).toDouble, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 0.44),
            FlSpot(6.8, 2.44),
            FlSpot(8, 0.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 1.44),
          ],
          isStepLineChart: true,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }


  //THis is the line chart of average data 

}