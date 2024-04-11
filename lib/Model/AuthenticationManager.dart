import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/DataManager/SleepDataManager.dart';
import 'package:sleeptrackerapp/Model/DataManager/UserDataManager.dart';

import 'dart:developer';


abstract class AuthenticationManager extends ChangeNotifier {
 bool get isAuthenticated;
 User? get currentUser;
 GoogleSignInAccount? get googleUser;  
 Future<void> authenticate(String username, String password);
 Future<void> loginWithEmailAndPassword({required String email,required String password, });
 Future<void> signInWithEmailAndPassword({required String email,required String password, });
 Future<void> googleLogin();
 Future<void> changesAuth();
 Future<void> subscribeChanges(); 

  // Future<void> authenticateWithGoogle();
  Future<void> signOut();
} 

class TestAuthenticationManagerImpl extends AuthenticationManager {
  @override
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false; 

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  
  @override
  Future<void> loginWithEmailAndPassword({required String email,required String password, }) async {

    try
    {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password).then((value) => _isAuthenticated = !_isAuthenticated);
    }
    catch(e)
    {
      // there were issues with firebase authentication
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    notifyListeners();  
  }

  @override
  Future<void> authenticate(String username, String password) async {
    if(username == "admin" && password == "password") {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  GoogleSignInAccount? user;
  @override
  GoogleSignInAccount get googleUser => user!;
  final googleSignIn = GoogleSignIn();


  @override
  Future<void> googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    user = googleUser;

    //Fetch the authentification
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    _isAuthenticated = true; 

    //print("THIS IS THE FIREBASE UID ${FirebaseAuth.instance.currentUser?.uid} and path ID/${firebaseAuth.currentUser?.uid}");

    // get the user data
    final userDB = GetIt.instance.get<UserDataManager>();

    // firebase path is /users/userID/$uid, users/userID is the path to the database
    String? uid = firebaseAuth.currentUser?.uid;
    if(uid == null)
    {
      return;
    }
    final userEntry = await userDB.getData(firebaseAuth.currentUser?.uid ?? '');



    // if the user is not in the database, add them
    if (userEntry == null) {
      UserDataEntry userData = UserDataEntry(
        userEmail: firebaseAuth.currentUser?.email ?? '',
        userName: firebaseAuth.currentUser?.displayName ?? '',
        wakeTimes: [ '00:00' , '00:00' , '00:00' , '00:00' , '00:00' , '00:00' , '00:00' ],
        sleepTimes: [ '00:00', '00:00', '00:00', '00:00', '00:00', '00:00', '00:00' ],
      );
      await userDB.addData(userData, key: uid);
      log('user added $uid ${userData.userEmail} ${userData.userName}');
    }
    else
    {
      // if the user is in the database, update their name and email
      userEntry.userEmail = firebaseAuth.currentUser?.email ?? '';
      userEntry.userName = firebaseAuth.currentUser?.displayName ?? '';
      await userDB.updateData(uid, userEntry);
      log('user updated ${userEntry.userEmail} ${userEntry.userName}');
    }
    
    // set the current user
    userDB.currentUser = userEntry;

    notifyListeners();
  }


@override
Future<void> changesAuth() async{
FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out! ----------------------------------------------------');
    } else {
      print('User is signed in! ------------------------------------------------');
    }
  });
}

@override
Future<void> subscribeChanges() async{
  FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out! idtoken-----------------------------------------------------');
    } else {
      print('User is signed in! idtoken--------------------------------------------------------------');
    }
  });
}

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    print("signOut???");
    googleSignIn.disconnect();
    await firebaseAuth.signOut();
    notifyListeners();
  }
}