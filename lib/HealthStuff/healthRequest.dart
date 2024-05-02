import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthRequest {

  List<HealthDataPoint> healthDataList = [];
  List<HealthDataPoint> heartRate = []; 
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  double rem = 0;
  double light = 0;
  double awake = 0;
  double deep = 0;
  double asleep = 0;
  double session = 0;
  double score = 0; 

  bool asleepSession = false;

  double min = 0;
  double max = 0;
  int Steps = 0; 

    final sleep = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
    ];

    final steps = HealthDataType.STEPS; 
    final ox = [HealthDataType.HEART_RATE]; ////
    double heartMaxY = 0; 
    double heartMinY = 0; 
    double heartMaxX = 0; 
    double heartMinX = 0; 
    double heartAvg = 0; 


    Future<bool> Validate(List<HealthDataType> T, List<HealthDataAccess>? permissions) async {
    final isGranted = await Permission.activityRecognition.isGranted;
    final isGranted2 = await Permission.location.isGranted;
    if (!isGranted) {
      await Permission.activityRecognition.request();
    }
    if (!isGranted2) {
      await Permission.location.request();
    }

    //final requested = await health.requestAuthorization(T, permissions: permissions);
    final hasPermission = await health.hasPermissions(T);
  //  print('${requested} and ${hasPermission}');
    if (hasPermission == true) {
      return true;
    } else {
      final requested = await health.requestAuthorization(T, permissions: permissions);
      if(requested){
        return true; 
      } else {
      return false;
      }
    }
  }

  Future<List<HealthDataPoint>> readSleep(String selectedDate) async { 
      rem = score = awake = light = deep = asleep = session = min = max = 0; 
      final permissions = sleep.map((e) => HealthDataAccess.READ_WRITE).toList();
      print(permissions);
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected = DateTime(selected.year, selected.month, selected.day);

    healthDataList.clear();
    if (await Validate(sleep, permissions)) {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(midnightSelected, selected, sleep);
      healthDataList.addAll((healthData.length < 300) ? healthData : healthData.sublist(0, 300));
      healthDataList = HealthFactory.removeDuplicates(healthDataList);
      healthDataList.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      for(var type in healthDataList ){
       // print('${type.dateFrom.minute} to -> ${type.dateTo.minute} and value ${type.value.toString()}'); 
      switch(type.typeString){
        case "SLEEP_AWAKE":
          awake += double.parse(type.value.toString()).toDouble(); 
          break;
        case "SLEEP_LIGHT":
          light += double.parse(type.value.toString()).toDouble();
          break;
        case "SLEEP_REM":
          rem += double.parse(type.value.toString()).toDouble();
          break; 
        case "SLEEP_DEEP":
          deep += double.parse(type.value.toString()).toDouble();
          break;
        case "SLEEP_ASLEEP":
          asleep += double.parse(type.value.toString()).toDouble();
          asleepSession = true; 
          break;
        case "SLEEP_SESSION":
          print('Sleep Session ----> ${type.value} ==> ( ${type.dateFrom} - ${type.dateTo} )');
          session = double.parse(type.value.toString()).toDouble(); 
          //session += double.parse(type.value.toString()).toDouble();
          min = type.dateFrom.millisecondsSinceEpoch.toDouble();
          max = type.dateTo.millisecondsSinceEpoch.toDouble();
          break; 
      }
    }

      Steps = (await health.getTotalStepsInInterval(midnightSelected, selected))!;
      score = (Steps * 0.005) + (deep * 0.25) + (rem * 0.25) + (session * 0.05); 
      //print("Sleep Score ${score}: (${Steps} * 0.005) + (${deep} * 0.25) + (${rem} * 0.25) + (${session} * 0.05)");
      return healthDataList;
    } else {
      print("You do not have permission and Authorization to access data");
      return healthDataList;
    }
  }

  Future<List<HealthDataPoint>> readHeartRate(String selectedDate) async {  
      final per = ox.map((e) => HealthDataAccess.READ_WRITE).toList();
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected = DateTime(selected.year, selected.month, selected.day);
    heartAvg = heartMinX = heartMaxX = heartMinY = heartMaxY = 0; 
    heartRate.clear();
    if (await Validate(ox, per)) {
      List<HealthDataPoint> bloodOxygen = await health.getHealthDataFromTypes(midnightSelected, selected, ox);
      heartRate.addAll((bloodOxygen.length < 300) ? bloodOxygen : bloodOxygen.sublist(0, 300));
      heartRate = HealthFactory.removeDuplicates(heartRate);
      heartRate.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      //print('${heartRate[0].dateFrom} and ${heartRate[heartRate.length - 1].dateFrom.millisecondsSinceEpoch.toDouble()}' ); 
      heartMaxX = heartRate[heartRate.length - 1].dateFrom.millisecondsSinceEpoch.toDouble(); 
      heartMinX = heartRate[0].dateFrom.millisecondsSinceEpoch.toDouble(); 

      heartMinY = double.parse(heartRate[0].value.toString()).toDouble(); 
      heartMaxY = double.parse(heartRate[0].value.toString()).toDouble(); 
      double countMax = 0; 
      for(var thing in heartRate){
          // print('date from -> ${thing.dateFrom} value -> ${thing.value} unit ${thing.unit}');
          countMax += double.parse(thing.value.toString()).toDouble();
          if(double.parse(thing.value.toString()).toDouble() < heartMinY){
              heartMinY = double.parse(thing.value.toString()).toDouble(); 
          } else if(double.parse(thing.value.toString()).toDouble() > heartMaxY){
              heartMaxY = double.parse(thing.value.toString()).toDouble(); 
          }
      }
      heartAvg = countMax / (heartRate.length); 
    //  print('minY = ${heartMinY}  && maxY = ${heartMaxY} avg ${heartAvg}');
      return heartRate;
    } else {
      print("You do not have permission and Authorization to access data");
      return heartRate;
    }
  }

}