import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SleepRecord
{
  double motion; // average motion
  double light; // average light
  int time;
  double sleepScore; // sleep score

  SleepRecord(this.motion, this.light, this.time, this.sleepScore);
}

///With this class the goal is to combine google user and email authorization into one variable whicih will be accessed to get user info 
///
abstract class currentUser extends ChangeNotifier {
  currentUser? f; 

  currentUser(String){



  }


@override
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<SleepRecord> _sleepRecords = [];

  @override
  Future<void> addSleepRecord(SleepRecord sleepRecord) async {
    _sleepRecords.add(sleepRecord);
    notifyListeners();
  }

  @override
  Future<void> deleteSleepRecord(SleepRecord sleepRecord) async {
    _sleepRecords.remove(sleepRecord);
    notifyListeners();
  }

}

