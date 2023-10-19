import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.title});
  final String title;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  @override
  Widget build(BuildContext context) {
    if(!GetIt.instance<AuthenticationManager>().isAuthenticated)
    {
      // navigate to the main page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer : const NavigationPanel(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Statistics Page'),
          ],
        ),
      ),
    );
  }
}
