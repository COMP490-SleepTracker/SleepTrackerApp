import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';


class HealthRequest {

  List<HealthDataPoint> healthDataList = [];
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
  double Steps = 0; 

    final sleep = [
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
    ];

    final steps = HealthDataType.STEPS; 


    Future<bool> Validate(List<HealthDataType> T, List<HealthDataAccess>? permissions) async {
    final isGranted = await Permission.activityRecognition.isGranted;
    final isGranted2 = await Permission.location.isGranted;
    if (!isGranted) {
      await Permission.activityRecognition.request();
    }
    if (!isGranted2) {
      await Permission.location.request();
    }

    final requested = await health.requestAuthorization(T, permissions: permissions);
    final hasPermission = await health.hasPermissions(T);
    if (requested == true && hasPermission == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<HealthDataPoint>> readSleep(String selectedDate) async { 
    rem = score = awake = light = deep = asleep = session = min = max = Steps = 0; 
    final permissions = sleep.map((e) => HealthDataAccess.READ_WRITE).toList();
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected = DateTime(selected.year, selected.month, selected.day);

    healthDataList.clear();
    if (await Validate(sleep, permissions)) {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(midnightSelected, selected, sleep);
      healthDataList.addAll((healthData.length < 300) ? healthData : healthData.sublist(0, 300));
      healthDataList = HealthFactory.removeDuplicates(healthDataList);
      healthDataList.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      //storage.storeData(healthDataList);   

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

      Steps = (await health.getTotalStepsInInterval(midnightSelected, selected))!.toDouble();
      score = (Steps * 0.005) + (deep * 0.25) + (rem * 0.25) + (session * 0.05); 
      //print("Sleep Score ${score}: (${Steps} * 0.005) + (${deep} * 0.25) + (${rem} * 0.25) + (${session} * 0.05)");
 
      return healthDataList;
    } else {
      print("You do not have permission and Authorization to access data");
      return healthDataList;
    }
  }

}