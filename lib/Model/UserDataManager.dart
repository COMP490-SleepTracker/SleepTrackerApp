import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleeptrackerapp/Utility/DatabaseStore.dart';

class UserDataEntry extends IRecord
{
  UserDataEntry({required this.ID, required this.userEmail, required this.userName});

  String ID;
  String userEmail;
  String userName;

  @override
  Map<String, dynamic> toJson() => {
    'ID': ID,
    'userEmail': userEmail,
    'userName': userName,
  };

  @override
  void fromJson(Map<String, dynamic> json) {
    ID = json['ID'];
    userEmail = json['userEmail'];
    userName = json['userName'];
  }


  factory UserDataEntry.fromJson(Map<String, dynamic> json) => UserDataEntry(
    ID: json['ID'],
    userEmail: json['userEmail'],
    userName: json['userName'],
  );
}

class UserDataManager extends DatabaseStore<UserDataEntry>
{ 

  @override
  String get databasePath => 'users/userID';

  @override
  UserDataEntry createRecord() => UserDataEntry(ID: '', userEmail: '', userName: '');
}