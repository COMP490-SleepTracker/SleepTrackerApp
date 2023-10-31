import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';


import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Model/SleepDataManager.dart';
import 'package:get_it/get_it.dart';

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
  Timer? accelerometerTimer;

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
    accelerometerTimer = Timer.periodic(const Duration(milliseconds: 250), (Timer t) => updateAccelerometerData());
    GetIt.instance<SleepDataManager>().addListener(update);

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            // add to our accelerometer data, average of x, y, z
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
        lightData.add(_luxValue!.toDouble());
        // remove first element if we have more than 20
        if (lightData.length > 20) {
          lightData.removeAt(0);
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
                  "It seems that your device doesn't support Light Sensor"),
            );
          });
    },
    cancelOnError: true,
    
    ));
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

  void updateAccelerometerData()
  {
    // since new accelerometer data comes in only when the user moves the phone, we want to add the last accelerometer value to our data
    // add it as the magnitude of the x, y, z values
    accelerometerData.add(sqrt(pow(_accelerometerValues![0], 2) + pow(_accelerometerValues![1], 2) + pow(_accelerometerValues![2], 2)));
    // remove first element if we have more than 20
    if (accelerometerData.length > 60) {
      accelerometerData.removeAt(0);
    }
  }

  void logSleepData()
  {
    // get average accelerometer value
    double accelerometerValue = 0;
    for(int i = 0; i < accelerometerData.length; i++)
    {
      accelerometerValue += (accelerometerData[i]).abs();
    }
    accelerometerValue /= accelerometerData.length;

    // get average light value

    bool lightDataAvailable = lightData.isNotEmpty;
    double lightValue = 0;
    for(int i = 0; i < lightData.length; i++)
    {
      lightValue += lightData[i];
    }
    lightValue /= lightData.length;

    // calculate sleep score
    // get our most recent sleep record to get the last sleep score
    SleepRecord? lastSleepRecord = GetIt.instance<SleepDataManager>().sleepRecords.lastOrNull;
    double lastSleepRecordScore = lastSleepRecord?.sleepScore ?? 0;
    // weight the accelerometer value more than the light value

    // adjust the accelerometer value to be between 0 and 1, clamp it to 0 and 1
    double adjustedAccelerometerValue = (accelerometerValue / 3).clamp(0, 1);
    // adjust the light value to be between 0 and 1, clamp it to 0 and 1
    double adjustedLightValue = (lightValue / 1000).clamp(0, 1);

    //weight each value
    adjustedAccelerometerValue *= 0.75;
    adjustedLightValue *= 0.25;

    // we want to have our sleep score be deltaed from the last sleep score
    double sleepScoreDelta = 100 / (adjustedAccelerometerValue + (lightDataAvailable ? adjustedLightValue : 0 ) + 1);

    // calculate the new sleep score by moving towards the delta
    double sleepScore = lastSleepRecordScore + (sleepScoreDelta - lastSleepRecordScore) / 100; // move 1% towards the delta


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
            Container(height: 150, width: 600, color: Theme.of(context).colorScheme.background, child: LineChartWidget(accelerometerData, 0, 3)),
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