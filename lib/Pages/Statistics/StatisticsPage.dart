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
  @override
  Widget build(BuildContext context) {
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

    Future<List<String>> returnAllTotal(List<HealthDataType> type) async {  
        List<String> t = [];      
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        final yesterday = now.subtract(Duration(hours: 24));


        HealthConnect e = GetIt.instance<HealthConnect>();  
        for(var data in type){
        t.add(await e.returnTotal(data,midnight,now));
        }
        return t; 
     }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} : FitBit analytics'),
      ),
      drawer : const NavigationPanel(),
       body:
             
         FutureBuilder(
            future: returnAllTotal(types),
            builder: (context,AsyncSnapshot<List<String>> snapshot) {
              if(snapshot.hasData){
                print(snapshot.data);
                  List<String>? data = snapshot.data;
                return ListView.builder(
                  itemCount: data?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(data![index]),
                    );
                  }
                );
          
              } else {
                return Center(child: CircularProgressIndicator(color: Colors.white));
              }
            }
      
    ),
  );
    
  }  
}    