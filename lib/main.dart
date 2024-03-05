import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Model/DataManager/HealthDataManager.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/DataManager/SleepDataManager.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Pages/Statistics/TestFitPage.dart';
import 'Model/AuthenticationManager.dart';
import 'Model/DataManager/SettingsManager.dart';
import 'package:sleeptrackerapp/firebase_options.dart';
import 'package:sleeptrackerapp/Model/DataManager/UserDataManager.dart';


import 'package:alarm/alarm.dart';
// void main() {
//   runApp(const MyApp());
// }

Future<void> main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );
  GetIt.instance.registerSingleton<AuthenticationManager>(TestAuthenticationManagerImpl());
  GetIt.instance.registerSingleton<SleepDataManager>(TestSleepDataManagerImpl());

  GetIt.instance.registerSingleton<HealthConnect>(HealthConnectStore());
  GetIt.instance.registerSingleton<HealthConnectDataManager>(HealthConnectDataManager());

  GetIt.instance.registerSingleton<SettingsManager>(SettingsManager());
  GetIt.instance.registerSingleton<UserDataManager>(UserDataManager());

  
  // init alarm
  await Alarm.init();
  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Tracker+',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const LoginPage(title: 'Sleep Tracker++'),
    );
  }
}

 