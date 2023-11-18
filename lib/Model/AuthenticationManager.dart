import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/SleepDataManager.dart';
import 'package:sleeptrackerapp/Model/UserDataManager.dart';
import 'package:sleeptrackerapp/Model/fitBit.dart';

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

    // get the user data
    final userDB = GetIt.instance.get<UserDataManager>();

    Query userQuery = userDB.database
    .orderByChild("ID")
    .equalTo(firebaseAuth.currentUser?.uid) 
    .limitToFirst(1);

    // call getDataByQuery
    List<UserDataEntry> userEntry = await userDB.getDataByQuery(userQuery);

    String? uid = firebaseAuth.currentUser?.uid;
    if(uid == null)
    {
      return;
    }


    // if the user is not in the database, add them
    if (userEntry.isEmpty) {
      UserDataEntry userData = UserDataEntry(
        userEmail: firebaseAuth.currentUser?.email ?? '',
        userName: firebaseAuth.currentUser?.displayName ?? '',
      );
      await userDB.addData(userData, key: uid);
      log('user added $uid ${userData.userEmail} ${userData.userName}');
    }
    else
    {
      // if the user is in the database, update their name and email
      UserDataEntry userData = userEntry.first;
      userData.userEmail = firebaseAuth.currentUser?.email ?? '';
      userData.userName = firebaseAuth.currentUser?.displayName ?? '';
      await userDB.updateData(uid, userData);
      log('user updated ${userData.userEmail} ${userData.userName}');
    }

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