import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sleeptrackerapp/Pages/Main/MainPage.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>(); 

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPage(title: 'Sleep Tracker+')),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/purpleblack.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, color: Colors.white);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      allowImplicitScrolling: true,

      pages: [
        PageViewModel(
          title: "Welcome to Sleep Tracker+",
          body: "Discover the secrets to better rest and wake up refreshed. Welcome to a more vibrant life with Sleep Tracker+!",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: ClipRRect(
                child: Image.asset(
                  'assets/sleep.png',
                ),
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "\n\nWhat is Sleep Tracker+?",
          body: "Sleep Tracker+ is your ultimate sleep companion! Explore your in-depth sleep statistics and increase your sleep quality with features like sleep statistics, sleep scores, an alarm, and a sleep schedule.",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: ClipRRect(  
                borderRadius: BorderRadius.circular(50.0),
                child: Image.asset(
                  'assets/sleep2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          decoration: pageDecoration,
          reverse: true,
        ),
        PageViewModel(
          title: "What do you need?\n",
          body: "A Fitbit - Inspire model preferred\n\nThe Fitbit App - Fitbit connection\n\nHealth Connect - Android connection \n\nGoogle Fit - Health Data connection",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: ClipRRect(  
                borderRadius: BorderRadius.circular(50.0),
                child: Image.asset(
                  'assets/fitbit.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
      PageViewModel(
        title: "Are you ready to transform your sleep?",
        body: "Let's dive in and make tonight the first of many well-rested nights ahead. Welcome to Sleep Tracker+!\n\nGo ahead and press 'Done' when you're ready.",
        image: _buildFullscreenImage(),
        decoration: pageDecoration.copyWith(
          contentMargin: const EdgeInsets.symmetric(horizontal: 16),
          fullScreen: true,
          bodyFlex: 10, 
          imageFlex: 6,
          safeArea: 100,
        ),
      ),

      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done'),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.deepPurple,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

//In case of button for returning back to the intro screen
void _onBackToIntro(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnBoardingPage()),
    );
}