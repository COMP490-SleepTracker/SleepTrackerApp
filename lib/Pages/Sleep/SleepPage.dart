import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';


import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Model/SleepDataManager.dart';
import 'package:get_it/get_it.dart';

import 'dart:async';

class LineChartWidget extends StatelessWidget {
  LineChartWidget(this.data, this.minY, this.maxY, {super.key}) : spots = data.asMap().map((i, value) {return MapEntry(i, FlSpot(i.toDouble(), value));}).values.toList()
  {
    spots = data
        .asMap()
        .map((i, value) {
          return MapEntry(i, FlSpot(i.toDouble(), value));
        })
        .values
        .toList();
  }

  final double minY;
  final double maxY;

  final List<double> data;
  List<FlSpot> spots;

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) {
      return Container();
    }
    final style = TextStyle(
      color: Colors.blueGrey,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 18 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: min(18, 18 * chartWidth / 300),
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(meta.formattedValue, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    // check if the user is authenticated
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        bottom: 12,
        right: 20,
        top: 20,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    maxContentWidth: 100,
                    tooltipBgColor: Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors[0] ??
                              touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return LineTooltipItem(
                          '${touchedSpot.x}, ${touchedSpot.y.toStringAsFixed(2)}',
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                ),
                lineBarsData: [
                  LineChartBarData(
                    color: Colors.white,
                    spots: spots,
                    isCurved: true,
                    isStrokeCapRound: true,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
                minY: minY,
                maxY: maxY,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          leftTitleWidgets(value, meta, constraints.maxWidth),
                      reservedSize: 56,
                    ),
                    drawBelowEverything: true,
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          bottomTitleWidgets(value, meta, constraints.maxWidth),
                      reservedSize: 36,
                      interval: 1,
                    ),
                    drawBelowEverything: true,
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1.5,
                  verticalInterval: 5,
                  checkToShowHorizontalLine: (value) {
                    return value.toInt() == 0;
                  },
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.blueGrey.withOpacity(0.5),
                    dashArray: [8, 2],
                    strokeWidth: 0.8,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: Colors.blueGrey.withOpacity(0.5),
                    dashArray: [8, 2],
                    strokeWidth: 0.8,
                  ),
                  checkToShowVerticalLine: (value) {
                    return value.toInt() == 0;
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SleepPage extends StatefulWidget {
  const SleepPage({super.key, required this.title});
  final String title;

  @override
  SleepPageState createState() => SleepPageState();
}

class SleepPageState extends State<SleepPage> {

  // timer to log sleep data from recent accelerometer and light data
  Timer? timer;

  List<double>? _accelerometerValues; //accelerometer values
  

  Light? _light; //light sensor
  int? _luxValue; //light value


  // for graph
  List<double> accelerometerData = [];
  List<double> lightData = [];

  final _streamSubscriptions = <StreamSubscription<dynamic>>[]; //stream subscription

  @override
  void initState() {

    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => logSleepData());
    GetIt.instance<SleepDataManager>().addListener(update);

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            // add to our accelerometer data, average of x, y, z
            accelerometerData.add((_accelerometerValues![0] + _accelerometerValues![1] + _accelerometerValues![2]) / 3);
            // remove first element if we have more than 20
            if (accelerometerData.length > 20) {
              accelerometerData.removeAt(0);
            }
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );

    //subscribe to light sensor
    _light = Light();
    try {
    _streamSubscriptions.add(_light!.lightSensorStream.listen((luxValue) {
      setState(() {
        _luxValue = luxValue;
        // add to our light data
        lightData.add(_luxValue!.toDouble());
        // remove first element if we have more than 20
        if (lightData.length > 20) {
          lightData.removeAt(0);
        }
      });
    }));
    } on LightException catch (e) {
      print(e);
    }
  }

    @override
  void dispose() {
    GetIt.instance<SleepDataManager>().removeListener(update);
    timer?.cancel();
    super.dispose();
  }

  void update()
  {
    setState(() {
    }); //update the widget
  }

  void logSleepData()
  {
    // get average accelerometer value
    double accelerometerValue = 0;
    for(int i = 0; i < accelerometerData.length; i++)
    {
      accelerometerValue += accelerometerData[i];
    }
    accelerometerValue /= accelerometerData.length;

    // get average light value
    double lightValue = 0;
    for(int i = 0; i < lightData.length; i++)
    {
      lightValue += lightData[i];
    }
    lightValue /= lightData.length;

    // calculate sleep score
    double sleepScore = 1000 / (accelerometerValue + lightValue + 1); // tmp

    // add to sleep data
    GetIt.instance<SleepDataManager>().addSleepRecord(SleepRecord(accelerometerValue, lightValue, DateTime.now().millisecondsSinceEpoch, sleepScore));
  }

  @override
  Widget build(BuildContext context) {
    SleepRecord? lastSleepRecord = GetIt.instance<SleepDataManager>().sleepRecords.lastOrNull;
    final userAccelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    // get the last 10 sleep vaues from the sleep records
    List<double> sleepValues = [];
    for(int i = GetIt.instance<SleepDataManager>().sleepRecords.length - 1; i >= 0 && i >= GetIt.instance<SleepDataManager>().sleepRecords.length - 10; i--)
    {
      sleepValues.add(GetIt.instance<SleepDataManager>().sleepRecords[i].sleepScore);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep'),
      ),
      drawer : const NavigationPanel(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('User Accelerometer: ${userAccelerometer ?? 'Not Available'}'),
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(accelerometerData, -10, 10)),
            Text('Light: ${_luxValue ?? 'Not Available'}'),
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(lightData, 0, 1000)),
            Text('Sleep Score: ${lastSleepRecord?.sleepScore ?? 'Not Available'}'),
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(sleepValues, 0, 1000))
          ],
        ),
      ),
    );
  }
}