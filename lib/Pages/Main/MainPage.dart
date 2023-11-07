import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:firebase_database/firebase_database.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {

    void testDB() async{
if (FirebaseAuth.instance.currentUser != null) {
      print('-------------------------------------------${FirebaseAuth.instance.currentUser?.displayName}');
      print('-------------------------------------------${FirebaseAuth.instance.currentUser?.email}');
      
    print('THis is working---------------------------------------${FirebaseAuth.instance.currentUser?.uid}');

    try{
     DatabaseReference db = FirebaseDatabase.instance.ref("users");
    final snapshot = await db.child('users/${FirebaseAuth.instance.currentUser?.uid}').get();
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
      print('What!?!? ================================ ${e}'); //[firebase_database/permission-denied] Client doesn't have permission to access the desired data.q
    }
    }
    }

  @override
  Widget build(BuildContext context) {
     final user = FirebaseAuth.instance.currentUser; 
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    } else {
      testDB();
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to Sleep Tracker -> '),
          ],  
        ), 
      ),
    );
  }
}


// class AuthData extends _MyHomePageState{


//   @override
//   Widget build(BuildContext context){

//   }


  // child: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
  //     builder: (context,snapshot) {
  //       return LoginPage(title: "Login"); 
  //     } ) ,  
