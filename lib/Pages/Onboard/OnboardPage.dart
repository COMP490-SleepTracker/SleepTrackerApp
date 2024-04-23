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
          title: "Welcome to Sleep Tracker++",
          body: "Let's get started!",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: Image.asset(
                'assets/sleep1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "What is Sleep Tracker++?",
          body: "Sleep Tracker++ blah blah lorem ipsum",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: Image.asset(
                'assets/sleep2.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "What do you need to use the app?",
          body: "Fitbit, Health Connect, Google Fit, and the Fitbit App",
          image: Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: SizedBox(
              width: double.infinity,
              height: 350.0,
              child: Image.asset(
                'assets/fitbit.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
      PageViewModel(
        title: "Are you ready to transform your sleep?",
        body: "Press 'Done' to go to the app!\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
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
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onBackToIntro(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnBoardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This is the screen after Introduction"),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _onBackToIntro(context),
              child: const Text('Back to Introduction'),
            ),
          ],
        ),
      ),
    );
  }
}