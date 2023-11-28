import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleeptrackerapp/Model/HealthDataManager.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:developer';



abstract class HealthConnect extends ChangeNotifier {

  //Future<List<HealthDataPoint>?> grabData(List<HealthDataType> T,DateTime setTime, DateTime now);
  Future<void> writeData(double data,HealthDataType T, DateTime setTime, DateTime now);
  Future<void> writeTestData();
  Future<void> ReadData(List<HealthDataType>? T,DateTime setTime, DateTime now);

}

//have this class extend database store? 
 class HealthConnectStore extends HealthConnect
{

  List<HealthDataPoint> healthDataList = [];
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  final types = [
    HealthDataType.STEPS,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT
  ];

  Future<bool> Validate(List<HealthDataType> T, List<HealthDataAccess>? permissions) async{
    final isGranted = await Permission.activityRecognition.isGranted;
    final isGranted2 = await Permission.location.isGranted;
    print("===================================================RESULT >>1 $isGranted");
    if (!isGranted) {
    await Permission.activityRecognition.request();
    } 
    if(!isGranted2){
    await Permission.location.request();
    }

    final requested = await health.requestAuthorization(T, permissions: permissions);
    final hasPermission = await health.hasPermissions(T);
    if(requested == true && hasPermission == true) {
      return true; 
    } else{
      return false; 
    }
  }

   Future<List<HealthDataPoint>?> ReadData(List<HealthDataType>? T,DateTime setTime, DateTime now) async{
    T ??= types;
    final permissions = T.map((e) => HealthDataAccess.READ_WRITE).toList();

    healthDataList.clear(); 
    if(await Validate(T,permissions)){
      print("READING DATA ----------------------------------------------------");
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(setTime,now, T);
      healthDataList.addAll((healthData.length < 100) ? healthData : healthData.sublist(0, 100));
      healthDataList = HealthFactory.removeDuplicates(healthDataList);
      print("================================================================");

      final userDB = GetIt.instance.get<HealthConnectDataManager>();

      for (var dataType in healthDataList) {
        print(dataType);

        Query userQuery = userDB.database
        .orderByChild("ID")
        .equalTo("$dataType") 
        .limitToFirst(1);

        List<HealthConnectDataEntry> userEntry = await userDB.getDataByQuery(userQuery);
          
          if(userEntry.isEmpty){
            HealthConnectDataEntry userData = HealthConnectDataEntry(
                dataType: dataType.typeString ,
                value: dataType.value.toString(),
                unit: dataType.unitString,
                dateFrom: dataType.dateFrom.toString(),
                dateTo: dataType.dateTo.toString()
            );
              await userDB.addData(userData, key: dataType.typeString);
          } else {
                HealthConnectDataEntry userData = userEntry.first;
                userData.dataType = dataType.typeString;
                userData.value = dataType.value.toString();
                userData.unit = dataType.unitString;
                userData.dateFrom = dataType.dateFrom.toString();
                userData.dateTo = dataType.dateTo.toString();
                await userDB.updateData(dataType.typeString, userData);
                log('user updated ${userData.dataType} ${userData.value} ${userData.unit} ${userData.dateFrom} ${userData.dateTo}');
          }
      
      }
      return healthDataList; 
    } else {
     print("You do not have permission and Authorization to access data");
     return null;
  }
  } 

  @override
  Future<void> writeData(double data,HealthDataType T, DateTime setTime, DateTime now) async{
    bool success = true;
    success &=await health.writeHealthData(data, T, setTime, now);
    print("Data has been entered? $success");
  }

   

    @override
  Future<void> writeTestData() async{
    final now = DateTime.now();
    final earlier = now.subtract(Duration(minutes: 20));
    bool success = true;
    success &=await health.writeHealthData(90, HealthDataType.STEPS, earlier, now);
    success &= await health.writeBloodOxygen(98, earlier, now, flowRate: 1.0);
    success &= await health.writeHealthData(10.0, HealthDataType.SLEEP_REM, earlier, now);
    success &= await health.writeHealthData(300.0, HealthDataType.SLEEP_ASLEEP, earlier, now);
    success &= await health.writeHealthData(100.0, HealthDataType.SLEEP_AWAKE, earlier, now);
    success &= await health.writeHealthData(50.0, HealthDataType.SLEEP_DEEP, earlier, now);   ////jj
    success &= await health.writeHealthData(170.0, HealthDataType.SLEEP_SESSION, earlier, now);
    success &= await health.writeHealthData(23.0, HealthDataType.SLEEP_LIGHT, earlier, now);
    print("Data has been entered? $success");
  }

  
  

}