import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:get_it/get_it.dart';

import 'package:firebase_auth/firebase_auth.dart';


// import 'package:firebase_database/firebase_database.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {

//     void testDB() async{

  @override
  Widget build(BuildContext context) {
     final user = FirebaseAuth.instance.currentUser; 
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    } else {
      //testDB();
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationPanel(),
      body:  Center(  //const was here 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to Sleep Tracker -> '),
            ElevatedButton(
            onPressed: () {
           GetIt.instance<AuthenticationManager>().signOut();
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
            }, 
            child: const Text('Sign out of google/firebase'),
      ),
      ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              final midnight = DateTime(now.year, now.month, now.day);  
            // GetIt.instance<HealthConnect>().writeTestData();  
             
            HealthConnect e = GetIt.instance<HealthConnect>();  
             var test = e.ReadData(null,midnight, now);
             print("========================================================================================================");
             
             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HealthApp()));
            }, 
            child: const Text('Test for Health Connect'),
      ),
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
