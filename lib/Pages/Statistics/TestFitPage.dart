import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';

import 'package:sleeptrackerapp/Widgets/StepGraph.dart';

import 'package:sleeptrackerapp/HealthStuff/healthRequest.dart';
import 'package:sleeptrackerapp/Widgets/SleepScore.dart';
import 'package:sleeptrackerapp/Widgets/Analysis.dart';
import 'package:sleeptrackerapp/Widgets/heartRate.dart';
import 'package:sleeptrackerapp/Widgets/tipsPage.dart';

class TestFitPage extends StatefulWidget {
  const TestFitPage({super.key, required this.title});
  final String title;

  @override
  State<TestFitPage> createState() => _TestFitPageState();
}

class _TestFitPageState extends State<TestFitPage> {
  TextEditingController date = TextEditingController();
  HealthRequest request = HealthRequest();
  @override
  Widget build(BuildContext context) {
    if (!GetIt.instance<AuthenticationManager>().isAuthenticated) {
      // navigate to the main page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }

    if (date.text == '') {
      date.text = DateTime.now().toString().split(' ')[0];
    }

    String getDate() {
      final now = DateTime.now();
      String selectedDate = '${date.text} ${now.toString().split(' ')[1]}';
      return selectedDate;
    }

    Future<void> calendar() async {
      DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(20000));

      if (picked != null) {
        setState(() {
          date.text = picked.toString().split(' ')[0];
        });
      } else {}
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} : FitBit analytics'),
      ),
      drawer: const NavigationPanel(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(
                top: 3,
                bottom: 10,
                right: 90), //test single child scroll widget
            child: TextField(
              controller: date,
              decoration: const InputDecoration(
                // labelText: 'Date',
                // filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                // enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                // focusedBorder: OutlineInputBorder(
                //     borderSide: BorderSide(color: Colors.blue)),
              ),
              readOnly: true,
              onTap: () => calendar(),
            ),
          )),
          FutureBuilder(
              future: request.readSleep(getDate()),
              builder:
                  (context, AsyncSnapshot<List<HealthDataPoint>> snapshot) {
                //Widget child;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasData) {
                  List<HealthDataPoint>? data = snapshot.data;
                  return Expanded(
                      child: Column(children: <Widget>[
                    Expanded(
                        child: ListView(children: <Widget>[
                      SleepScore(request.score),

                      ///add a list type view below this one
                      SizedBox(height: 10),
                      Analysis(
                          request.light,
                          request.awake,
                          request.asleep,
                          request.deep,
                          request.rem,
                          request.Steps,
                          request.session,
                          request.Steps),

                      SleepGraph(data, request.max, request.min,
                          request.asleepSession),

                      tips(request.score),
                      /////
                      FutureBuilder(
                          future: request.readHeartRate(getDate()),
                          builder: (context,
                              AsyncSnapshot<List<HealthDataPoint>> snapshot) {
                            //Widget child;
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white));
                            } else if (snapshot.hasData) {
                              List<HealthDataPoint>? heart = snapshot.data;
                              return heartRateGraph(heart, request.heartMaxX, request.heartMinX, request.heartMaxY, request.heartMinY,request.heartAvg);
                            } else if (snapshot.hasError) {
                              print(snapshot.error);
                              return Container(); //or text but this is to furfill null req
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white));
                            }
                          })
                          //////
                    ])),
                  ]));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
              })
        ],
      ),
    );
  }
}
