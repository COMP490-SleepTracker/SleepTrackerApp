import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:get_it/get_it.dart';
// import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';

class SleepRecord {
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

////////////////////////////////////

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


////Firebase DB
  Future<void> LoginDataInFirebase(String email, String name, String userID) async {
    DatabaseReference db = FirebaseDatabase.instance.ref("users");

    final snapshot = await db.child('users/${userID}').get();
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available.');
      await db.set({
        "userEmail": email,
        "userID": userID,
        "userName": name
      });
    }
  }
}
