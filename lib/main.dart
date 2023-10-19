import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Model/SleepDataManager.dart';
import 'package:get_it/get_it.dart';
import 'Model/AuthenticationManager.dart';

void main() {
  GetIt.instance.registerSingleton<AuthenticationManager>(TestAuthenticationManagerImpl());
  GetIt.instance.registerSingleton<SleepDataManager>(TestSleepDataManagerImpl());
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
      home: const LoginPage(title: 'Sleep Tracker+'),
    );
  }
}