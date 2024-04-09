import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

    int currentSleepScore = (stepsmath + deepmath + remmath + sleeptimemath);
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

    List<TipInfo> tips = [];

    // Randomly select a tip based on the current sleep score threshold
    Random random = Random();

    if (currentSleepScore >= 89) {
      //GREAT SLEEPSCORE
      tips = [
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description: 'Continue to exercise regularly, as studies show it can reduce stress, improve mood, and increase the production of melatonin.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description: 'Continue to avoid high-intensity exercise within 2 to 3 hours of bedtime, as it can raise your core body temperature and delay sleep onset. Morning exercise, coupled with exposure to natural light, can help regulate your sleep-wake cycle and promote better sleep at night.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description: 'Continue to regulate your stress levels. When you worry about things that may go wrong, your body keeps you awake to manage the danger. As a result, it can take you longer to sleep and may even wake you up in the middle of the night.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
      ];
    } else if (currentSleepScore >= 68) {
      tips = [
        //GOOD SLEEPSCORE
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Give yourself time to wind down before bed.To relax, try deep breathing exercises. Inhale slowly and deeply, and then exhale.',
          url: 'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Avoid eating a big meal within two to three hours of bedtime. If you are hungry right before bed, eat a small healthy snack (such as an apple with a slice of cheese or a few whole-wheat crackers) to satisfy you until breakfast.',
          url: 'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Exercise is great but avoid exercising too close to bedtime. Morning workouts that expose you to bright daylight will help the natural circadian rhythm.',
          url: 'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
      ];
    } else if (currentSleepScore >= 47) {
      //OKAY SLEEPSCORE
      tips = [
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'If you don’t fall asleep after 20 minutes, get out of bed. Go do a quiet activity without a lot of light exposure. ',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Turn off electronic devices at least 30 minutes before bedtime.',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Keep a consistent sleep schedule. Get up at the same time every day, even on weekends or during vacations.',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
      ];
    } else {
      //BAD SLEEPSCORE
      tips = [
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Make sure your bedroom is quiet, dark, relaxing, and at a comfortable temperature',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Avoid large meals, caffeine, and alcohol before bedtime',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description: 'Get some exercise. Being physically active during the day can help you fall asleep more easily at night.',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),

      ];
    }

    // Randomly select a tip to display
    TipInfo selectedTip = tips[random.nextInt(tips.length)];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
      ),
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
            child: TipCard(
              title: selectedTip.title,
              description: selectedTip.description,
              url: selectedTip.url,
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
  final String url;

  const TipCard({
    Key? key,
    required this.title,
    required this.description,
    required this.url,
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
            const SizedBox(height: 8.0), // Separate line
            Text.rich(
              TextSpan(
                text: 'Click here to find out more',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchURL(url); // Function to launch URL
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class TipInfo {
  final String title;
  final String description;
  final String url;

  TipInfo({
    required this.title,
    required this.description,
    required this.url,
  });
}
