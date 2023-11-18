import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';



class fitbitFootSteps {
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  fitbitFootSteps(this.value, this.unit, this.dateFrom, this.dateTo);
}



abstract class fitBitManager extends ChangeNotifier {
  Future<void> fitBitTest(); 
  Future<void> authorize();

}

  enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}

////////////////////////////////////

class TestfitBit extends fitBitManager {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
    AppState _state = AppState.DATA_NOT_FETCHED;


  // define the types to get
  static final types = [
    HealthDataType.STEPS,
    //HealthDataType.BLOOD_GLUCOSE,
   // HealthDataType.SLEEP_SESSION,
    //HealthDataType.SLEEP_ASLEEP,
    //HealthDataType.SLEEP_IN_BED,
   // HealthDataType.SLEEP_AWAKE,
   // HealthDataType.SLEEP_REM,
  ];



  final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();

  @override
  Future<void> authorize() async {
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    await Permission.activityRecognition.request();

    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

   _state = (authorized) ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED;
   print("THiS TESTS IF PERMISSIONS IS AUTHORIZED $_state");

   fitBitTest();
  }


  @override
  Future<void> fitBitTest()async {
    print("helllo this is the fitBitTest -=====================================================");
   _state = AppState.FETCHING_DATA;

  List<HealthDataPoint> _healthDataList = [];

// requesting access to the data types before reading them
  bool requested = await health.requestAuthorization(types);

  print("this is testing the requested data for health ----------> $requested");

  // get data within the last 24 hours
    final now = DateTime.now().subtract(Duration(days: 1));
    final yesterday = now.subtract(Duration(days: 2));

  print("DATE NOW $now");
  print("YESTERDAY $yesterday");
  print("PERMISSIONS $permissions");

    // Clear old data points
    _healthDataList.clear();

  try {
      // fetch health data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(yesterday,now, types);


          print("====================================================================S");
      // save all the new data points (only the first 100)
      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));

      print("The list ===========================================================================================================================");
      _healthDataList.forEach((element) {print("test this --> $element");});
    } catch (error) {
      print("------------------Exception in getHealthDataFromTypes: $error");
    }

    _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;

    print("===================================================================================  $_state");

  }

}
