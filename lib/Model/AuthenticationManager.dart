import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/SleepDataManager.dart';
import 'package:sleeptrackerapp/Model/fitBit.dart';



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
    final DB = FirebaseDatabase.instance.ref();
    final userDB = DB.child('users/userID');


    // await userDB.push().set({
    //     "userEmail": firebaseAuth.currentUser?.email,
    //     "ID": firebaseAuth.currentUser?.uid,
    //     "userName": firebaseAuth.currentUser?.displayName
    //   });


    // //Works Read Data ---> expect 1 output 
    Query myjsdQuery = userDB // the parent Reference
    .orderByChild("ID") // the property to search on
    .equalTo(firebaseAuth.currentUser?.uid) // return children that have "name"="jehe"
    .limitToFirst(1);

    DataSnapshot e =  await myjsdQuery.get();
    
   Map<dynamic, dynamic> data = e.value! as Map<dynamic, dynamic>;
   
    final k = Map<String, dynamic>.from(e.value as Map);
    // final jj = k["ID"] as String; 
    // print("if this works, ill kys $jj");
   // Map<dynamic, dynamic> map = snapshot.data.snapshot.value;

    print("THIS IS k.values ${k.values}");
    print("this is length of k.values ${k.values.length}");
    print("this is k.key ${k.keys}");


    //This prints out the String for uid from firebase
    print(k.values.toList()[0]["ID"]);
    /////
    
    // GetIt.instance<SleepDataManager>().LoginDataInFirebase(firebaseAuth.currentUser?.email,firebaseAuth.currentUser?.displayName,firebaseAuth.currentUser?.uid ); 
    GetIt.instance<fitBitManager>().fitBitTest(); 



  
  //26:10 
 //print("WITH [0]" + k[0]);


//      print('test1');
//     for (dynamic type in k.keys) {
//     k[type.toString()] = k[type];
//  }
//     String? test = data["ID"];
//     print('FUCKING Work plz --------------------- ${data}'); 



  //   if (e.exists) {
  //   (e as List).forEach((child) {
  //     Map<dynamic, dynamic> data = child.value! as Map<dynamic, dynamic>;
  //     String? userType = data["ID"] as String?;
  //     print('User type: $userType');
  //   });
  // } else {
  //   print('No data found for email: ${firebaseAuth.currentUser?.uid}');
  // }

    
    // userDB.onValue.listen((event){
    //   print('---------------------------------');
    //   final Object? testMe = event.snapshot.value;  //diplay all the data    
    // });




    //  List<Year> years = new List<Year>();

    // FirebaseDatabase.instance
    //     .reference()
    //     .child("year")
    //     .once()
    //     .then((DataSnapshot snapshot) {
    //       //here i iterate and create the list of objects
    //       Map<dynamic, dynamic> yearMap = snapshot.value;
    //       yearMap.forEach((key, value) {
    //         years.add(Year.fromJson(key, value));
    //       });

    

    }catch(e){
      print(e);
    }



/*
    try{
     DatabaseReference db = FirebaseDatabase.instance.ref("users/userID");
    final snapshot = await db.child('users/userID/${firebaseAuth.currentUser?.uid}').get();
    print('AMM HERE');
    if (snapshot.exists) {
      print(snapshot.value);
    } else {
      print('No data available-----------------------------.');
      await db.set({
        "userEmail": firebaseAuth.currentUser?.email,
        "userID": firebaseAuth.currentUser?.uid,
        "userName": firebaseAuth.currentUser?.displayName
      });
    }

    } catch(e){
      print('What!?!? ================================ ${e}');
    } 
    */


    _isAuthenticated = true; 
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