
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Settings/SettingsPage.dart';
import 'package:sleeptrackerapp/Pages/Sleep/SleepPage.dart';

class NavigationPanel extends Drawer
{
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Sleep Tracker+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage(title: 'Sleep Tracker+')) );
            },
          ),
          ListTile(
            title: const Text('Sleep'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SleepPage(title: 'Sleep')));
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsPage(title: 'Settings')));
            },
          ),
        ],
      ),
    );
  }
}