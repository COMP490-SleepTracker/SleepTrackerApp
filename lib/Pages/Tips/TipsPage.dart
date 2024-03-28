import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // Define the maximum sleep score
    const double maxSleepScore = 110.0;
    
// Assuming you have fetched the health data for steps, deep, rem, and sleeptime
  double stepsValue = 4583; // Example value for steps from 11.28
  double deepValue = 41; // Example value for deep sleep from 11.28
  double remValue = 69; // Example value for REM sleep from 11.28
  double sleeptimeValue = 241; // Example value for sleep time from 11.28

  // Define the multipliers
  double stepsMultiplier = 0.005;
  double deepMultiplier = 0.25;
  double remMultiplier = 0.25;
  double sleeptimeMultiplier = 0.05;

  // Perform mathematical operations on the health data using multipliers
  int stepsmath = (stepsValue * stepsMultiplier).toInt();
  int deepmath = (deepValue * deepMultiplier).toInt();
  int remmath = (remValue * remMultiplier).toInt();
  int sleeptimemath = (sleeptimeValue * sleeptimeMultiplier).toInt();
  
 

  int currentSleepScore =(stepsmath + deepmath + remmath + sleeptimemath);
    // Calculate the scaled sleep score percentage
    final double sleepScorePercentage = currentSleepScore / maxSleepScore;

    // Retrieve the color of the circular progress indicator
    String sleepQuality = '';
    Color progressColor = Colors.green;

    // Determine sleep quality and progress color
    if (currentSleepScore >= 89) {
      sleepQuality = 'Great';
      progressColor = Colors.green;
    } else if (currentSleepScore >= 68) {
      sleepQuality = 'Good';
      progressColor = Colors.yellow;
    } else if (currentSleepScore >= 47) {
      sleepQuality = 'Okay';
      progressColor = Colors.orange;
    } else {
      sleepQuality = 'Bad';
      progressColor = Colors.red;
    }

    String tipTitle = '';
    String tipDescription = '';

    // Determine which tip to display based on the current sleep score
    if (currentSleepScore >= 89) {
      tipTitle = 'Tip 1';
      tipDescription = 'INSERT "GREAT" SLEEP SCORE HEALTH TIP HERE';
    } else if (currentSleepScore >= 68) {
      tipTitle = 'Tip 2';
      tipDescription = 'INSERT "GOOD" SLEEP SCORE HEALTH TIP HERE';
    } else if (currentSleepScore >= 47) {
      tipTitle = 'Tip 3';
      tipDescription = 'INSERT "OKAY" SLEEP SCORE HEALTH TIP HERE';
    } else {
      tipTitle = 'Tip 4';
      tipDescription = 'INSERT "BAD" SLEEP SCORE HEALTH TIP HERE';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
      ),
      drawer: const NavigationPanel(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your Sleep Score:',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 13.0),
                Container(
                  width: 100.0,
                  height: 100.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120.0, // Size of the circular progress indicator
                        height: 120.0,
                        child: CustomCircularProgressIndicator(
                          value: sleepScorePercentage, // Use scaled sleep score percentage
                          progressColor: progressColor,
                        ),
                      ),
                      Text(
                        currentSleepScore.toStringAsFixed(0), // Display the current sleep score
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.bold,
                          color: progressColor, // Use the same color as the progress indicator
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  sleepQuality, // Display sleep quality
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: progressColor, // Use the same color as the progress indicator
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                TipCard(
                  title: tipTitle,
                  description: tipDescription,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final double value;
  final Color progressColor;

  const CustomCircularProgressIndicator({
    Key? key,
    required this.value,
    required this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: value,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      strokeWidth: 13.0,
    );
  }
}

class TipCard extends StatelessWidget {
  final String title;
  final String description;

  const TipCard({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
