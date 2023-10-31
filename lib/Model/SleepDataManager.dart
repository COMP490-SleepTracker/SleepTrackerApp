import 'package:flutter/material.dart';

class SleepRecord
{
  double motion; // average motion
  double light; // average light
  int time;
  double sleepScore; // sleep score

  SleepRecord(this.motion, this.light, this.time, this.sleepScore);
}

abstract class SleepDataManager extends ChangeNotifier {
  List<SleepRecord> get sleepRecords;
  
  Future<void> addSleepRecord(SleepRecord sleepRecord);
  Future<void> deleteSleepRecord(SleepRecord sleepRecord);
}

class TestSleepDataManagerImpl extends SleepDataManager {
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