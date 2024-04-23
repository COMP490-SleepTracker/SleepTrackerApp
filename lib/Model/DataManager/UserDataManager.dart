import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleeptrackerapp/Utility/DatabaseStore.dart';

class UserDataEntry extends IRecord
{
  UserDataEntry({required this.userEmail, required this.userName, required this.wakeTimes, required this.sleepTimes});

  String userEmail;
  String userName;
  
  // wake times
  List<String> wakeTimes = [];
  // sleep times
  List<String> sleepTimes = [];


  @override
  Map<String, dynamic> toJson() => {
    'userEmail': userEmail,
    'userName': userName,
    'wakeTimes': wakeTimes,
    'sleepTimes': sleepTimes,
  };

  @override
  void fromJson(Map<String, dynamic> json) {
    userEmail = json['userEmail'];
    userName = json['userName'];
    wakeTimes = List<String>.from(json['wakeTimes']);
    sleepTimes = List<String>.from(json['sleepTimes']);
  }


  factory UserDataEntry.fromJson(Map<String, dynamic> json) => UserDataEntry(
    userEmail: json['userEmail'],
    userName: json['userName'],
    wakeTimes : List<String>.from(json['wakeTimes']),
    sleepTimes : List<String>.from(json['sleepTimes']),
  );
}

class UserDataManager extends DatabaseStore<UserDataEntry>
{ 

  @override
  String get databasePath => 'users/userID';

  @override
  UserDataEntry createRecord() => UserDataEntry(userEmail: '', userName: '', wakeTimes: [], sleepTimes: []);

  UserDataEntry? currentUser;

  Future<void> updateCurrentUser(UserDataEntry data) async => await updateData(firebaseAuth.currentUser?.uid ?? '', data);
}