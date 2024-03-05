import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';
import 'package:sleeptrackerapp/Widgets/HealthConnectGraph.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sleeptrackerapp/Widgets/HealthConnectBarGraph.dart';

import 'package:sleeptrackerapp/Widgets/StepGraph.dart';



class TestFitPage extends StatefulWidget {
  const TestFitPage({super.key, required this.title});
  final String title;

  @override
  State<TestFitPage> createState() => _TestFitPageState();
}

class _TestFitPageState extends State<TestFitPage> {
  TextEditingController date = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> t = [];

    List<HealthDataPoint> healthDataList = [];
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

    
    double rem = 0;
    double light = 0;
    double awake = 0;
    double deep = 0; 
    double asleep = 0; 
    double session = 0;

    double min = 0; 
    double max = 0; 


    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT
    ];

    final sleep = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT
    ];

    if (!GetIt.instance<AuthenticationManager>().isAuthenticated) {
      // navigate to the main page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    if (date.text == '') {
      date.text = DateTime.now().toString().split(' ')[0];
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Future<bool> Validate(List<HealthDataType> T, List<HealthDataAccess>? permissions) async {
    final isGranted = await Permission.activityRecognition.isGranted;
    final isGranted2 = await Permission.location.isGranted;
    print(
        "===================================================RESULT >>1 $isGranted");
    if (!isGranted) {
      await Permission.activityRecognition.request();
    }
    if (!isGranted2) {
      await Permission.location.request();
    }

    final requested =
        await health.requestAuthorization(T, permissions: permissions);
    final hasPermission = await health.hasPermissions(T);
    print("===================================================RESULT >>permisson $hasPermission");
    if (requested == true && hasPermission == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<HealthDataPoint>> ReadRawData(List<HealthDataType> T) async { 
    final permissions = T.map((e) => HealthDataAccess.READ_WRITE).toList();

      final now = DateTime.now();
      String selectedDate = '${date.text} ${now.toString().split(' ')[1]}';
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected =
      DateTime(selected.year, selected.month, selected.day);

    healthDataList.clear();
    if (await Validate(T, permissions)) {
      print(
          "READING DATA ----------------------------------------------------");
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(midnightSelected, selected, T);
      // for(var type in healthData){
      //   //healthDataList.add(type);
      // }
      //print(healthData.length);
      healthDataList.addAll(
      (healthData.length < 300) ? healthData : healthData.sublist(0, 300));
      healthDataList = HealthFactory.removeDuplicates(healthDataList);

      healthDataList.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

       for(var type in healthDataList ){
       // print('${type.dateFrom.minute} to -> ${type.dateTo.minute} and value ${type.value.toString()}'); 
      switch(type.typeString){
        case "SLEEP_AWAKE":
        awake += double.parse(type.value.toString()).toInt(); 
        break;
        case "SLEEP_LIGHT":
        light += double.parse(type.value.toString()).toInt();
        break;
        case "SLEEP_REM":
        rem += double.parse(type.value.toString()).toInt();
        break; 
        case "SLEEP_DEEP":
        deep += double.parse(type.value.toString()).toInt();
        break;
        case "SLEEP_ASLEEP":
        asleep += double.parse(type.value.toString()).toInt();
        break;
        case "SLEEP_SESSION":
        print('Sleep Session ----> ${type.value} ==> ( ${type.dateFrom} - ${type.dateTo} )');

        session += double.parse(type.value.toString()).toInt();
        min = type.dateFrom.millisecondsSinceEpoch.toDouble();
        max = type.dateTo.millisecondsSinceEpoch.toDouble();
      }

    }    
      return healthDataList;
    } else {
      print("You do not have permission and Authorization to access data");
      return healthDataList;
    }
  }

    Future<List<String>> returnAllTotal(List<HealthDataType> type) async {
      final now = DateTime.now();
      String selectedDate = '${date.text} ${now.toString().split(' ')[1]}';
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected =
          DateTime(selected.year, selected.month, selected.day);
          print('TESTING SELECTED DATES ${selectedDate} to ${midnightSelected}' );
      HealthConnect e = GetIt.instance<HealthConnect>();
      for (var data in type) {
        t.add(await e.returnTotal(data, midnightSelected, selected));
      }
      return t;
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////

    Future<void> calendar() async {
      DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(20000));

      if (picked != null) {
        setState(() {
          date.text = picked.toString().split(' ')[0];
        });
      } else {}
    }   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} : FitBit analytics'),
      ),
      drawer: const NavigationPanel(),
      body: Column(
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(30),
            child: TextField(
              controller: date,
              decoration: const InputDecoration(
                labelText: 'Date',
                filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              readOnly: true,
              onTap: () => calendar(),
            ),
          )),
          //Focus on sleep 
          FutureBuilder(
              future: ReadRawData(sleep), 
              builder: (context, AsyncSnapshot<List<HealthDataPoint>> snapshot) {
                if (snapshot.hasData) {
                  //final date2 = DateTime.now();
                  //print(snapshot.data);
                  List<HealthDataPoint>? data = snapshot.data;
                  return Expanded(
                    child: Column(children: <Widget>[
                     // LineChartSample2(data),
                     Expanded(child: SleepGraph(data,max,min)), 
                   //  Expanded(child: BarChartSample1(rem,light,deep,asleep,awake,session)),                       
                      ])
                  );
                } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); 
                }else {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

              }
              ) 
        ], //children --> add more future bulder's such as steps, blood pressure and so on 
      ),
    );
  }
}
