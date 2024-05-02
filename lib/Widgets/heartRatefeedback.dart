import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class heartRateFeedback extends StatelessWidget {
  final double avgHeartRate;
  List<feedback> TheTip = [];
  late feedback selectedTip;

  heartRateFeedback(this.avgHeartRate) {   //40-59 60-79 80 - 90 100
    if (avgHeartRate <= 40 && avgHeartRate >= 59) {
      //GREAT SLEEPSCORE
      TheTip = [
        feedback(
          title: 'You maintained a low sleeping heart rate throughout your sleep.',
          description:
              'It is normal to have a low heart rates below the range for a typical resting heart rate, and it is actually considered to indicate a healthy heart rate. A possible cause of a low heart rate during sleep is due to long periods in deep state of sleep. ',
          url: 'https://www.sleepfoundation.org/physical-health/sleeping-heart-rate#:~:text=During%20sleep%2C%20it%20is%20normal,vary%20depending%20on%20multiple%20factors.',
        ),
      ];
    } else if (avgHeartRate <= 79 && avgHeartRate >= 60) {
      TheTip = [
         feedback(
          title: 'You maintained a normal heart rate throughout your sleep.',
          description:
              'A heart rate of ${avgHeartRate.toStringAsFixed(1)} is generally normal for young adults.Your heart rate falls within a healthy range, indicating that your heart is efficiently pumping blood throughout your body, which is essential for overall health and fitness.',
          url: 'https://www.sleepfoundation.org/physical-health/sleeping-heart-rate#:~:text=During%20sleep%2C%20it%20is%20normal,vary%20depending%20on%20multiple%20factors.',
        ),
        
      ];
    } else if (avgHeartRate <= 90 && avgHeartRate >= 80) {
      //OKAY SLEEPSCORE
      TheTip = [
         feedback(
          title: 'You maintained a little high but normal sleeping heart rate.',
          description:
              ' A heart rate of ${avgHeartRate.toStringAsFixed(1)} is slightly elevated compared to the typical resting heart rate range but may still be within normal limits for some individuals, depending on factors like age, fitness level, and overall health. By taking proactive steps to monitor and manage your resting heart rate, you can support your cardiovascular health and overall well-being. ',
          url: 'https://www.sleepfoundation.org/physical-health/sleeping-heart-rate#:~:text=During%20sleep%2C%20it%20is%20normal,vary%20depending%20on%20multiple%20factors.',
        ),
   
      ];
    } else if(avgHeartRate >= 91){
      //BAD SLEEPSCORE
      TheTip = [
         feedback(
          title: 'You maintained a high sleeping heart rate.',
          description:
              'You experienced a high sleeping heart rate throughout your sleep. This can be a result of stress and anxiety or poor hygiene. Nightmares can also increase your heartrate. ',
          url: 'https://www.sleepfoundation.org/physical-health/sleeping-heart-rate#:~:text=During%20sleep%2C%20it%20is%20normal,vary%20depending%20on%20multiple%20factors.',
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
      heartFeedback(
        title: selectedTip.title,
        description: selectedTip.description,
        url: selectedTip.url,
      );
      // Text('test')
   // );
  }
}

class heartFeedback extends StatelessWidget {
  final String title;
  final String description;
  final String url;

  const heartFeedback({
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

class feedback {
  final String title;
  final String description;
  final String url;

  feedback({
    required this.title,
    required this.description,
    required this.url,
  });
}