
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import '../NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/SettingsButton.dart';
import 'AlarmPage.dart';

import 'SleepSchedulePage.dart';
import 'package:get_it/get_it.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});
  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer : const NavigationPanel(),
      body: Column(
          children: [
            // button to forward to the sleep schedule page, full width
            SettingsButton(
              child: const Text('Sleep Schedule'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SleepSchedulePage(title: 'Sleep Schedule')),
                );
              },
            ), 
            SettingsButton(
              onPressed: () {
              GetIt.instance<AuthenticationManager>().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
            }, 
            child: const Text('Sign out of google/firebase'),
          ),
           SettingsButton(
              child: const Text('Alarm Settings'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlarmPage(title: 'Alarm Settings')),
                );
            })
          
            
          ],
        )
      );
  }
}