import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_database/firebase_database.dart';


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


    print('THis is working---------------------------------------${firebaseAuth.currentUser?.uid}');

    try{
     DatabaseReference db = FirebaseDatabase.instance.ref("users");
    final snapshot = await db.child('users/${firebaseAuth.currentUser?.uid}').get();
    print('AMM HERE');
    // if (snapshot.exists) {
    //   print(snapshot.value);
    // } else {
    //   print('No data available-----------------------------.');
    //   await db.set({
    //     "userEmail": firebaseAuth.currentUser?.email,
    //     "userID": firebaseAuth.currentUser?.uid,
    //     "userName": firebaseAuth.currentUser?.displayName
    //   });
    // }

    } catch(e){
      print('What!?!? ================================ ${e}');
    }
    _isAuthenticated = true; 
    notifyListeners();
  }

@override
Future<void> changesAuth() async{
FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
}

@override
Future<void> subscribeChanges() async{
  FirebaseAuth.instance
  .idTokenChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
}

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    await firebaseAuth.signOut();
    notifyListeners();
  }
}