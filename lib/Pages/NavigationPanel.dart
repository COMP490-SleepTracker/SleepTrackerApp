
import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';
import 'package:sleeptrackerapp/Pages/Settings/SettingsPage.dart';
import 'package:sleeptrackerapp/Pages/Sleep/SleepPage.dart';
import 'package:sleeptrackerapp/Pages/Journal/JournalPage.dart';
import 'package:sleeptrackerapp/Pages/Statistics/TestFitPage.dart';
import 'package:sleeptrackerapp/Pages/Statistics/StatsPage.dart';
import 'package:sleeptrackerapp/Pages/BarGraphPage.dart';


class NavigationPanel extends Drawer
{
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {           // TestFitPage tempStatsPage
    List<Widget> pages = [const MainPage(title: 'Sleep Tracker+'), const SleepPage(title: 'Sleep'), const tempStatsPage(title: 'Statistics'), const JournalPage(title: 'Journal'), const SettingsPage(title: 'Settings'), const BarGraphPage(title: 'Graphs')];
    List<String> titles = ['Sleep Tracker+', 'Sleep', 'Sleep Analysis', 'Journal', 'Settings','Graphs'];
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
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [                
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset('assets/sleep.png', height: 50),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 15.0), 
                  child: Text(
                    'Sleep Tracker+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),

              ],
            ),
          ),
          ...navigationTiles,
        ],
      ),
    );
  }
}