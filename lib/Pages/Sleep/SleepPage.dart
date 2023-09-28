import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key, required this.title});
  final String title;

  @override
  SleepPageState createState() => SleepPageState();
}

class SleepPageState extends State<SleepPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep'),
      ),
      drawer : const NavigationPanel(),
      body: const Center(
        child: Text(
          'Sleep',
        ),
      ),
    );
  }
}