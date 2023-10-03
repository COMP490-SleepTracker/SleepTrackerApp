import 'package:flutter/material.dart';
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
