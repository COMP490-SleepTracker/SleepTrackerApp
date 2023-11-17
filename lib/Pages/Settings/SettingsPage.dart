
import 'package:flutter/material.dart';
import '../NavigationPanel.dart';
import 'package:sleeptrackerapp/Widgets/SettingsButton.dart';
import 'SleepSchedulePage.dart';

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
            )
          ],
        )
      );
  }
}