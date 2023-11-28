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
  // Future<void> LoginDataInFirebase(String? email, String? name, String? userID);
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


/////////////
////////////////Firebase DB
  // @override
  // Future<void> LoginDataInFirebase(String? email, String? name, String? userID) async {
  //   try{
  //   final DB = FirebaseDatabase.instance.ref();
  //   final userDB = DB.child('users/userID');

  //   //make the query to check if snapshot exists-->Then you push.set the user data into firebase DB 

  //   //This will push userdata into RT database located in 'users/userID';  
  //   await userDB.push().set({
  //       "userEmail":  FirebaseAuth.instance.currentUser?.email,
  //       "ID":  FirebaseAuth.instance.currentUser?.uid,
  //       "userName":  FirebaseAuth.instance.currentUser?.displayName
  //     });
  // } catch (e){
  //   print(e);
  // }
  // }


  // Future<void> userDateFirebase(int w) async{
  //  try{
  //   final DB = FirebaseDatabase.instance.ref();
  //   final userDB = DB.child('users/userID');

  //   //This will push userdata into RT database located in 'users/userID';  
  //   await userDB.push().set({
  //       "ID":  FirebaseAuth.instance.currentUser?.uid,
  //       "Date": w,
  //     });
  // } catch (e){
  //   print(e);
  // }
  // }


  
//var database = FirebaseDatabase.instance.ref();  ///subcription 
var userDBSubscription = FirebaseDatabase.instance.ref().child('users/userID').onChildAdded.listen((event){

  print("THIS SuBSCRIBTION IS FULLY WORKING for on Child added" );

  
});

var userDBRemoved = FirebaseDatabase.instance.ref().child('users/userID').onChildChanged.listen((event){

  print("THIS SuBSCRIBTION IS FULLY WORKING for on child changed ");
});



// Future<void> TESTDB(int w) async{

// //every user must have an email
// DatabaseEvent e = await FirebaseDatabase.instance.ref().child('users/userID').orderByChild("ID").equalTo(FirebaseAuth.instance.currentUser?.uid)
// .once();

// if(e.snapshot.exists){
//   print("HELLO I EXIST");

// } else {
//   print("HELLO I Do NOT EXIST");
// }
//   }


}
