import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class tips extends StatelessWidget {
  final double sleepScore;
  List<TipInfo> TheTip = [];
  late TipInfo selectedTip;

  tips(this.sleepScore) {
    if (sleepScore >= 89) {
      //GREAT SLEEPSCORE

      TheTip = [
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description:
              'Continue to exercise regularly, as studies show it can reduce stress, improve mood, and increase the production of melatonin.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description:
              'Continue to avoid high-intensity exercise within 2 to 3 hours of bedtime, as it can raise your core body temperature and delay sleep onset. Morning exercise, coupled with exposure to natural light, can help regulate your sleep-wake cycle and promote better sleep at night.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
        TipInfo(
          title: 'Tip to help maintain your sleepscore:',
          description:
              'Continue to regulate your stress levels. When you worry about things that may go wrong, your body keeps you awake to manage the danger. As a result, it can take you longer to sleep and may even wake you up in the middle of the night.',
          url: 'https://amerisleep.com/blog/exercise-and-sleep/',
        ),
      ];
    } else if (sleepScore >= 68) {
      TheTip = [
        //GOOD SLEEPSCORE
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Give yourself time to wind down before bed.To relax, try deep breathing exercises. Inhale slowly and deeply, and then exhale.',
          url:
              'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Avoid eating a big meal within two to three hours of bedtime. If you are hungry right before bed, eat a small healthy snack (such as an apple with a slice of cheese or a few whole-wheat crackers) to satisfy you until breakfast.',
          url:
              'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Exercise is great but avoid exercising too close to bedtime. Morning workouts that expose you to bright daylight will help the natural circadian rhythm.',
          url:
              'https://www.health.harvard.edu/newsletter_article/8-secrets-to-a-good-nights-sleep',
        ),
      ];
    } else if (sleepScore >= 47) {
      //OKAY SLEEPSCORE
      TheTip = [
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'If you don’t fall asleep after 20 minutes, get out of bed. Go do a quiet activity without a lot of light exposure. ',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Turn off electronic devices at least 30 minutes before bedtime.',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Keep a consistent sleep schedule. Get up at the same time every day, even on weekends or during vacations.',
          url: 'https://sleepeducation.org/healthy-sleep/healthy-sleep-habits/',
        ),
      ];
    } else {
      //BAD SLEEPSCORE
      TheTip = [
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Make sure your bedroom is quiet, dark, relaxing, and at a comfortable temperature',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Avoid large meals, caffeine, and alcohol before bedtime',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),
        TipInfo(
          title: 'Tip to help improve your sleepscore:',
          description:
              'Get some exercise. Being physically active during the day can help you fall asleep more easily at night.',
          url: 'https://www.sleepfoundation.org/sleep-hygiene',
        ),
      ];
    }

    selectedTip = TheTip[Random().nextInt(TheTip.length)];
  }

  @override
  Widget build(BuildContext context) {
    return 
    //Expanded(
  //    child: 
      TipCard(
        title: selectedTip.title,
        description: selectedTip.description,
        url: selectedTip.url,
      );
      // Text('test')
   // );
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

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
