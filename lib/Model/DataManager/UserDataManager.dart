import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleeptrackerapp/Utility/DatabaseStore.dart';

class UserDataEntry extends IRecord
{
  UserDataEntry({required this.userEmail, required this.userName});

  String userEmail;
  String userName;

  @override
  Map<String, dynamic> toJson() => {
    'userEmail': userEmail,
    'userName': userName,
  };

  @override
  void fromJson(Map<String, dynamic> json) {
    userEmail = json['userEmail'];
    userName = json['userName'];
  }


  factory UserDataEntry.fromJson(Map<String, dynamic> json) => UserDataEntry(
    userEmail: json['userEmail'],
    userName: json['userName'],
  );
}

class UserDataManager extends DatabaseStore<UserDataEntry>
{ 

  @override
  String get databasePath => 'users/userID/${FirebaseAuth.instance.currentUser?.uid}';

  @override
  UserDataEntry createRecord() => UserDataEntry(userEmail: '', userName: '');
}