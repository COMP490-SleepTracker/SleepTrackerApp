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
            padding: const EdgeInsets.only(top: 3, bottom: 10, right: 90),
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
                if (snapshot.hasData) {
                  List<HealthDataPoint>? data = snapshot.data;
                  return 
                  //Expanded(
                     // child: 
                    Column(children: <Widget>[
                    SleepScore(request.session, request.deep, request.rem, request.Steps,request.score),  ///add a list type view below this one 
                    Analysis(request.light,request.awake,request.asleep,request.deep,request.rem,request.Steps,request.session),
                    SleepGraph(data, request.max, request.min,
                            request.asleepSession),
                  ]);
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
