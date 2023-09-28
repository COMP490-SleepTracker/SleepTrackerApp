
import 'package:flutter/material.dart';
import '../NavigationPanel.dart';

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
      body: const Center(
        child: Text(
          'Settings',
        ),
      ),
    );
  }
}