import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleeptrackerapp/Model/DataManager/HealthDataManager.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:developer';

class totalList {
  totalList({required this.dataType, required this.value, required this.unit});

  String dataType;
  String value;
  String unit;
}

abstract class HealthConnect extends ChangeNotifier {
  Future<void> writeData(
      double data, HealthDataType T, DateTime setTime, DateTime now);
  Future<void> writeTestData();
  Future<List<HealthDataPoint>?> ReadRawData(List<HealthDataType>? T, DateTime setTime, DateTime now);
  Future<String> returnTotal(HealthDataType type, DateTime time, DateTime now);
}

class HealthConnectStore extends HealthConnect {
  List<HealthDataPoint> healthDataList = [];
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  final types = [
    HealthDataType.STEPS,
    //HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT
  ];

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
    if (requested == true && hasPermission == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<List<HealthDataPoint>?> ReadRawData(List<HealthDataType>? T, DateTime setTime, DateTime now) async {
    T ??= types;
    final permissions = T.map((e) => HealthDataAccess.READ_WRITE).toList();

    healthDataList.clear();
    if (await Validate(T, permissions)) {
      print(
          "READING DATA ----------------------------------------------------");
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(setTime, now, T);
      // for(var type in healthData){
      //   healthDataList.add(type);
      // }
      print(healthData.length);
      healthDataList.addAll(
          (healthData.length < 300) ? healthData : healthData.sublist(0, 300));
      healthDataList = HealthFactory.removeDuplicates(healthDataList);

      print(healthDataList);
      // print("============HeaalthDATA=======================================");

      // for (var dataType in healthDataList) {
      //   if (dataType.sourceName == "com.fitbit.FitbitMobile") {
      //     print('dataType: ${dataType.typeString} , value: ${dataType.value.toString()} ,unit: ${dataType.unitString},dateFrom: ${dataType.dateFrom.toString()} ,dateTo: ${dataType.dateTo.toString()}, source: ${dataType.sourceName}');
      //   }
      // }
      return healthDataList;
    } else {
      print("You do not have permission and Authorization to access data");
      return healthDataList;
    }
  }

  String durationToString(int minutes) {
    var d = Duration(minutes:minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')} hr ${parts[1].padLeft(2, '0')} min';
    }

  @override
  Future<String> returnTotal(HealthDataType type, DateTime time, DateTime now) async {
    int total = 0;

    String returnString = '${type.name} : No Data';

    if (type == HealthDataType.STEPS) {
         final permissions = HealthDataAccess.READ_WRITE;
         if(await Validate([type],[permissions])){
            total = (await health.getTotalStepsInInterval(time, now))!.toInt();
            returnString = 'Total STEPS : $total steps';
        }
    } else {
        await ReadRawData([type], time, now);
          for (var dataType in healthDataList) {
            if (dataType.sourceName == "com.fitbit.FitbitMobile") {
              if (dataType.type == type) {
                total += double.parse(dataType.value.toString()).toInt();
              }
            }
          }

        if(healthDataList.isNotEmpty){
          if(type == HealthDataType.HEART_RATE){
            total = total ~/ healthDataList.length;
            returnString = '${healthDataList[0].typeString} : $total Beats per Minute';
          } else {
             if(healthDataList[0].unitString == 'MINUTE'){
              if(total > 60){
                String hours = durationToString(total);
                returnString = '${healthDataList[0].typeString} : $hours';
              } else {
                returnString = '${healthDataList[0].typeString} : $total min';
              } 
              } 
          }
        } 
    }
    return returnString;
  }


  @override
  Future<void> writeData(
      double data, HealthDataType T, DateTime setTime, DateTime now) async {
    bool success = true;
    success &= await health.writeHealthData(data, T, setTime, now);
    print("Data has been entered? $success");
  }

  @override
  Future<void> writeTestData() async {
    print(
        "writing data ==================================================================================");

    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));
    bool success = true;
    success &=
        await health.writeHealthData(90, HealthDataType.STEPS, earlier, now);
    success &= await health.writeBloodOxygen(98, earlier, now, flowRate: 1.0);
    success &= await health.writeHealthData(
        10.0, HealthDataType.SLEEP_REM, earlier, now);
    success &= await health.writeHealthData(
        300.0, HealthDataType.SLEEP_ASLEEP, earlier, now);
    success &= await health.writeHealthData(
        100.0, HealthDataType.SLEEP_AWAKE, earlier, now);
    success &= await health.writeHealthData(
        50.0, HealthDataType.SLEEP_DEEP, earlier, now); ////jj
    success &= await health.writeHealthData(
        170.0, HealthDataType.SLEEP_SESSION, earlier, now);
    success &= await health.writeHealthData(
        23.0, HealthDataType.SLEEP_LIGHT, earlier, now);
    print("Data has been entered? $success");
  }
}





            // Query userQuery = userDB.database
            // .orderByChild("ID")
            // .equalTo("$dataType")
            // .limitToFirst(1);

            // List<HealthConnectDataEntry> userEntry = await userDB.getDataByQuery(userQuery);

            //   if(userEntry.isEmpty){
            //     HealthConnectDataEntry userData = HealthConnectDataEntry(
            //         dataType: dataType.typeString ,
            //         value: dataType.value.toString(),
            //         unit: dataType.unitString,
            //         dateFrom: dataType.dateFrom.toString(),
            //         dateTo: dataType.dateTo.toString()
            //     );
            //       await userDB.addData(userData, key: dataType.typeString);
            //   } else {
            //         HealthConnectDataEntry userData = userEntry.first;
            //         userData.dataType = dataType.typeString;
            //         userData.unit = dataType.unitString;
            //         userData.dateFrom = dataType.dateFrom.toString();
            //         userData.dateTo = dataType.dateTo.toString();
            //         await userDB.updateData(dataType.typeString, userData);
            //         //log('user updated ${userData.dataType} ${userData.value} ${userData.unit} ${userData.dateFrom} ${userData.dateTo}');
            //   }