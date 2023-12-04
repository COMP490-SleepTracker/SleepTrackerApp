import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:sleeptrackerapp/Model/healthConnect.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key, required this.title});
  final String title;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  TextEditingController date = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> t = [];

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT
    ];

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

    Future<List<String>> returnAllTotal(List<HealthDataType> type) async {
      final now = DateTime.now();
      String selectedDate = '${date.text} ${now.toString().split(' ')[1]}';
      final DateTime selected = DateTime.parse(selectedDate);
      final DateTime midnightSelected =
          DateTime(selected.year, selected.month, selected.day);
      HealthConnect e = GetIt.instance<HealthConnect>();
      for (var data in type) {
        t.add(await e.returnTotal(data, midnightSelected, selected));
      }
      return t;
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
        children: [
          Center(
              child: Padding(
            padding: EdgeInsets.all(30),
            child: TextField(
              controller: date,
              decoration: const InputDecoration(
                labelText: 'Date',
                filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              readOnly: true,
              onTap: () => calendar(),
            ),
          )),
          FutureBuilder(
              future: returnAllTotal(types),
              builder: (context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.hasData) {
                  //final date2 = DateTime.now();
                  print(snapshot.data);
                  List<String>? data = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: data?.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data![index]),
                          );
                        }),
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
              }) 
        ], //children
      ),
    );
  }
}
