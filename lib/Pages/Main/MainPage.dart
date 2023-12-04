import 'package:flutter/material.dart';
import 'package:health/health.dart';
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

  @override
  Widget build(BuildContext context) {
    testThis() async {
              final now = DateTime.now();
              final midnight = DateTime(now.year, now.month, now.day);
              final yesterday = now.subtract(Duration(hours: 24));
              final midnight2 = DateTime(yesterday.year, yesterday.month, yesterday.day);

       HealthConnect e = GetIt.instance<HealthConnect>();  
        List<HealthDataPoint>? test = await e.ReadRawData([HealthDataType.STEPS],midnight, now);
        print("========================================================================================================");
        print('now $now');
        print(' yesterday $yesterday');
        print('midnight $midnight');


        String totalSteps = await e.returnTotal(HealthDataType.STEPS,yesterday,midnight);
        print("TOTAL STEPS $totalSteps");

        // String avgHeart = await e.returnTotal(HealthDataType.HEART_RATE,midnight,now);
        // print("avgHeartRate $avgHeart");

        // String totalDeep = await e.returnTotal(HealthDataType.SLEEP_REM,yesterday,now);
        // print("DEEP $totalDeep");
  }

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
      // ElevatedButton(
      //       onPressed: () {
      //          final now = DateTime.now();
      //         final midnight = DateTime(now.year, now.month, now.day);
      //         final yesterday = now.subtract(Duration(hours: 24));
      //         testThis();
      //        print('$now');
      //        print('$midnight');
      //       }, 
      //       child: const Text('Test for Health Connect'),
      // ),
          ],  
        ), 
      ),
    );
  }
}


