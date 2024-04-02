
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Settings/SettingsPage.dart';
import 'package:sleeptrackerapp/Pages/Sleep/SleepPage.dart';
import 'package:sleeptrackerapp/Pages/Journal/JournalPage.dart';
import 'package:sleeptrackerapp/Pages/Statistics/TestFitPage.dart';
import 'package:sleeptrackerapp/Pages/BarGraphPage.dart';
import 'package:sleeptrackerapp/Pages/Tips/TipsPage.dart';


class NavigationPanel extends Drawer
{
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [const MainPage(title: 'Sleep Tracker+'), const SleepPage(title: 'Sleep'), const TestFitPage(title: 'Statistics'), const JournalPage(title: 'Journal'), const SettingsPage(title: 'Settings'), const TipsPage(title:'Tips'), const BarGraphPage(title: 'Graphs')];
    List<String> titles = ['Sleep Tracker+', 'Sleep', 'Statistics', 'Journal', 'Settings', 'Tips','Graphs'];
    List<Icon> icons = [const Icon(Icons.home), const Icon(Icons.bedtime), const Icon(Icons.bar_chart), const Icon(Icons.book), const Icon(Icons.settings), const Icon(Icons.lightbulb), const Icon(Icons.analytics_outlined)];
    List<Widget> navigationTiles = [];
    for (int i = 0; i < pages.length; i++)
    {
      navigationTiles.add(ListTile(
        title: Text(titles[i]),
        leading: icons[i],
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => pages[i]));
        },
      ));
    }

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
          ...navigationTiles,
        ],
      ),
    );
  }
}