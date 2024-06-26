import 'package:flutter/widgets.dart';
import 'package:health/health.dart';
import 'package:sleeptrackerapp/Model/DataManager/SecureStorage.dart';
import 'package:sleeptrackerapp/Widgets/StepGraph.dart';
import 'package:sleeptrackerapp/Widgets/CardSleepGraph.dart';


class SleepRequest{
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  List<HealthDataType> datatypes = [
    HealthDataType.SLEEP_SESSION, 
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM];


  var startTimes = List<DateTime>.filled(7, DateTime(0));
  var endTimes = List<DateTime>.filled(7, DateTime(0));
  List<HealthDataPoint> sleepdata = List.empty();
  List<HealthDataPoint> sleepPoints = List.empty();
  List<HealthDataPoint> heartData = List.empty();
  List<double> weekHours = [0,0,0,0,0,0,0];
  List<double> weekScores = [0,0,0,0,0,0,0];
  List<double> sessions = [0,0,0,0,0,0,0]; List<double> rems = [0,0,0,0,0,0,0];
  List<double> deeps = [0,0,0,0,0,0,0]; List<double> lights = [0,0,0,0,0,0,0];
  List<double> awakes = [0,0,0,0,0,0,0]; List<double> asleeps = [0,0,0,0,0,0,0];
  List<double> mins = [0,0,0,0,0,0,0]; List<double> maxs = [0,0,0,0,0,0,0];
  List<int> steps = [0,0,0,0,0,0,0];
  double heartMinY = 0, heartMaxY = 0, heartAvg = 0;
  double weekAvg = 0.0;
  double sleepDebt = 0.0;
  double sleepDebtTemp = 0.0;
  DateTime today = DateTime.now();
  bool loaded = false;
  List<Widget> sleepCharts = [Container(), Container(), Container(), Container(), Container(), Container(), Container()];


  List<HealthDataPoint> sleepSessions = List.empty();
  _getSteps(DateTime sunday)async{
    for(int i = 0; i < 7; i++){
      steps[i]  = (await health.getTotalStepsInInterval(sunday, sunday.add(const Duration(days: 1))) ?? 0);
      sunday = sunday.add(const Duration(days: 1));
    }
  }

  Future<void> getHeartRate(int index)async {
    if(mins[index]==0) {heartAvg = heartMinY = heartMaxY = 0; return;}
    List<HealthDataType> heartType = [HealthDataType.HEART_RATE];
    if(await health.hasPermissions(heartType) == false){
      await health.requestAuthorization(heartType);
    }
    heartData = await health.getHealthDataFromTypes(
      DateTime.fromMillisecondsSinceEpoch(mins[index].toInt()), 
      DateTime.fromMillisecondsSinceEpoch(maxs[index].toInt()), 
      heartType);
    if(heartData.isEmpty) return;

    heartMinY = heartMaxY = double.parse(heartData[0].value.toString());
    double countMax = 0;

    for(var point in heartData){
      double value = double.parse(point.value.toString());
      countMax += value;
      if(value < heartMinY){heartMinY = value;} 
      else if(value > heartMaxY){heartMaxY = value;}
    }
    heartAvg = countMax / heartData.length;
  }

  //initialize healthdata for a specific week (Must be called first)
  Future<void> weekSleepData(DateTime sunday) async {
     if(await health.hasPermissions(datatypes) == false){
      await health.requestAuthorization(datatypes);
     }

    sleepdata = await health.getHealthDataFromTypes(sunday, sunday.add(const Duration(days: 8)), datatypes);
    sleepdata.sort((a,b) => a.dateFrom.compareTo(b.dateFrom));
    loaded = true;

    await _getSteps(sunday);
    _sleepHours(sunday);
    _sleepScores(sunday);
  }

  Future<void> stepGraphData(DateTime sunday) async{
    if(await health.hasPermissions(datatypes) == false){
      await health.requestAuthorization(datatypes);
    }
    sleepPoints = await health.getHealthDataFromTypes(sunday, sunday.add(const Duration(days: 8)), datatypes);
    sleepPoints.sort((a,b) => a.dateFrom.compareTo(b.dateFrom));
  }

  Future<bool> tryReadStorage(DateTime sunday) async {
    sleepPoints = List.empty();
    String hours = await SecureStorage().readSecureData("Week - $sunday");
    
    if(hours.isNotEmpty && (today.isAfter(sunday.add(const Duration(days: 7))) || loaded)){
      String avg = await SecureStorage().readSecureData("Avg - $sunday");
      String scores = await SecureStorage().readSecureData("Scores - $sunday");
      String starts = await SecureStorage().readSecureData("StartTimes - $sunday");
      String ends = await SecureStorage().readSecureData("EndTimes - $sunday");
      String sess = await SecureStorage().readSecureData("Sessions - $sunday");
      String awks = await SecureStorage().readSecureData("Awakes - $sunday");
      String rms = await SecureStorage().readSecureData("Rems - $sunday");
      String deep = await SecureStorage().readSecureData("Deeps - $sunday");
      String lghts = await SecureStorage().readSecureData("Lights - $sunday");
      String asleep = await SecureStorage().readSecureData("Asleeps - $sunday");
      String min = await SecureStorage().readSecureData("Mins - $sunday");
      String max = await SecureStorage().readSecureData("Maxs - $sunday");
      String step = await SecureStorage().readSecureData("Steps - $sunday");

      weekHours = parseDoubleList(hours);
      weekAvg = double.parse(avg);
      weekScores = parseDoubleList(scores);
      startTimes = parseDateList(starts);
      endTimes = parseDateList(ends);
      sessions = parseDoubleList(sess);
      awakes = parseDoubleList(awks);
      rems = parseDoubleList(rms);
      deeps = parseDoubleList(deep);
      lights = parseDoubleList(lghts);
      asleeps = parseDoubleList(asleep);
      mins = parseDoubleList(min);
      maxs = parseDoubleList(max);
      steps = parseIntList(step);
      return true;
    }
    return false;
  }

  //set sleep_session data into appropriate days and return hours slept for the week
  void _sleepHours(DateTime sunday) {
    weekHours = [0,0,0,0,0,0,0];
    startTimes = List<DateTime>.filled(7, DateTime(0));
    endTimes = List<DateTime>.filled(7, DateTime(0));
    sleepSessions = sleepdata.where((element) => element.type == HealthDataType.SLEEP_SESSION).toList();
    sleepSessions = _trimEnds(sleepSessions, sunday);
    if(sleepSessions.isEmpty) {return;}
    sleepdata.removeWhere((element) => 
    element.dateFrom.isBefore(sleepSessions.first.dateFrom) || 
    element.dateTo.isAfter(sleepSessions.last.dateTo));

    sleepPoints = sleepdata.where((element) => element.type != HealthDataType.SLEEP_SESSION).toList();
    _setDayHours(sleepSessions, sunday);
  }

  List<HealthDataPoint> _trimEnds(List<HealthDataPoint> sleepSessions, DateTime sunday) {
      if (sleepSessions.isEmpty) return sleepSessions;
      if(sleepSessions[0].dateTo.isBefore(sunday.add(const Duration(days: 1))) && //Checks if first sleep of the week ended before Monday
         int.parse(sleepSessions[0].value.toString()) > 90){ //Only trims out sleep longer than 90mins to prevent trimming sunday naps
        sleepSessions.removeAt(0);
      }
      if (sleepSessions.isEmpty) return sleepSessions;
      if(sleepSessions.last.dateFrom.day != sunday.day && //last entry is not this sunday
      sleepSessions.last.dateFrom.weekday == 7 && //last entry was on next sunday
      sleepSessions.last.dateFrom.day != sleepSessions.last.dateTo.day){ // started on sunday, ended on monday
        sleepSessions.removeLast();
      }
      return sleepSessions;
    }
    
  void _setDayHours(List<HealthDataPoint> sleepSessions, DateTime sunday) {
    for(HealthDataPoint point in sleepSessions){
      DateTime dateFrom = point.dateFrom; DateTime dateTo = point.dateTo;
      double value = double.parse(point.value.toString());

      if(dateFrom.day == dateTo.day){ //Sleep session begun and ended on same day
        if (value > 90) { //Sleep session was not a nap (longer than 90mins)
          weekHours[dateTo.weekday-1] += value;
          if(startTimes[dateTo.weekday-1] == DateTime(0)) {
            startTimes[dateTo.weekday-1] = dateFrom;
          }
          endTimes[dateTo.weekday-1] = dateTo;
        }
        else{ //Was a nap
          if(dateFrom.weekday == 7){ //Nap was on sunday
            weekHours[0] += value;
            startTimes[0] = dateFrom;
            endTimes[0] = dateTo;
          }
          else{ //Nap was not on sunday
            weekHours[dateFrom.weekday] += value;
            startTimes[dateFrom.weekday] = dateFrom;
            endTimes[dateFrom.weekday] = dateTo;
          }
        }
      }
      else if(dateFrom.weekday < 7){ //Sleep did not begin on a Sunday
        weekHours[dateFrom.weekday] += value;
        startTimes[dateFrom.weekday] = dateFrom;
        endTimes[dateFrom.weekday] = dateTo;
      }
      else{
        weekHours[0] += value;
        startTimes[0] = dateFrom;
        endTimes[0] = dateTo;
      }
    }
  }
  
  void _sleepScores(DateTime sunday) {
    weekScores = [0,0,0,0,0,0,0]; awakes = [0,0,0,0,0,0,0];
    lights = [0,0,0,0,0,0,0]; rems = [0,0,0,0,0,0,0];
    deeps = [0,0,0,0,0,0,0]; sessions = [0,0,0,0,0,0,0];
    sleepCharts = [Container(),Container(),Container(),Container(),Container(),Container(),Container()];
    for(int i = 0; i < 7; i++){
      if(startTimes[i] == DateTime(0)) continue;
      double awake = 0, light = 0, rem = 0, deep = 0, asleep = 0, session = 0, min = 0, max = 0;
      
      // double min = 0, max = 0; 
       bool asleepS = false; 
      DateTime end = endTimes[i];
      var toRemove = [];

      for(var point in sleepdata){
        if(point.dateFrom.isAfter(end)){
          break;
        }
          double value = double.parse(point.value.toString());
        switch(point.typeString){
        case "SLEEP_AWAKE":
          awake += value;
          break;
        case "SLEEP_LIGHT":
          light += value; 
          break;
        case "SLEEP_REM": 
          rem += value;
          break; 
        case "SLEEP_DEEP":
          deep += value;
          break;
        case "SLEEP_ASLEEP":
          asleep += value;
          asleepS = true; 
          break;
        case "SLEEP_SESSION":
          session += value;
          // min = point.dateFrom.millisecondsSinceEpoch.toDouble();
          // max = point.dateTo.millisecondsSinceEpoch.toDouble();
          if(value > 90){
            min = point.dateFrom.millisecondsSinceEpoch.toDouble();
            max = point.dateTo.millisecondsSinceEpoch.toDouble();}
          break;
      }
      toRemove.add(point);
      }
      sleepdata.removeWhere((element) => toRemove.contains(element));
      _setDataPoints(i,session, awake, rem, deep, light, asleep, min, max);
      weekScores[i] = _calculateScore(session, awake, rem, deep, light);
      sleepCharts[i] = CardSleepGraph(sleepdata, max, min, asleepS);
    }
    weekAvg = _getAvg(sunday);
    _storeDataPoints(sunday);
    return;
  }

  double _calculateScore(double session, double awake, double rem, double deep, double light) {
    double duration = session-awake;
    double remPercent = rem / session * 100;
    double deepPercent = deep / session * 100;
    double lightPercent = light / session * 100;
    double awakePercent = awake / session * 100;
    
    double timeScore; double remScore; double deepScore;
    double lightScore; double awakeScore;
    
      if(duration >= 480) {timeScore = 1;}
      else {timeScore = duration/480;}
      
      remScore = remPercent/25;
      deepScore = deepPercent/25;
      lightScore = lightPercent/50;
      awakeScore = awakePercent * 0.8;

      if(light == 0){
        return -1;
      }
      double score =  (timeScore*50)+(remScore*15)+(deepScore*15)+(lightScore*20)-(awakeScore);
      return score.roundToDouble();
  }

  void _setDataPoints(int i, double session, double awake, double rem, double deep, double light, double asleep, double min, double max) {
    sessions[i] = session;
    awakes[i] = awake;
    rems[i] = rem;
    deeps[i] = deep;
    lights[i] = light;
    asleeps[i] = asleep;
    mins[i] = min;
    maxs[i] = max;
  }
  
  void _storeDataPoints(DateTime sunday) {
      SecureStorage().writeSecureData("Week - $sunday", "$weekHours");
      SecureStorage().writeSecureData("Scores - $sunday", "$weekScores");
      SecureStorage().writeSecureData("Avg - $sunday", "$weekAvg");

      SecureStorage().writeSecureData("Sessions - $sunday", "$sessions");
      SecureStorage().writeSecureData("Awakes - $sunday", "$awakes");
      SecureStorage().writeSecureData("Rems - $sunday", "$rems");
      SecureStorage().writeSecureData("Deeps - $sunday", "$deeps");
      SecureStorage().writeSecureData("Lights - $sunday", "$lights");
      SecureStorage().writeSecureData("Asleeps - $sunday", "$asleeps");
      SecureStorage().writeSecureData("Mins - $sunday", "$mins");
      SecureStorage().writeSecureData("Maxs - $sunday", "$maxs");
      SecureStorage().writeSecureData("Steps - $sunday", "$steps");

      SecureStorage().writeSecureData("StartTimes - $sunday", "$startTimes");
      SecureStorage().writeSecureData("EndTimes - $sunday", "$endTimes");
  }

    ///Converts [String] value from storage into [List] of [double] values
  List<double> parseDoubleList(String value) {
   value = value.replaceAll(RegExp(r'[[\]]'), '');
   List<String> list = value.split(',');
   List<double> list2 = list.map(double.parse).toList();
   return list2;
  }

  List<int> parseIntList(String value) {
    value = value.replaceAll(RegExp(r'[[\]]'), '');
    List<String> list = value.split(',');
    List<int> list2 = list.map(int.parse).toList();
    return list2;
  }

  List<DateTime> parseDateList(String value) {
   value = value.replaceAll(RegExp(r'[[\]]'), '');
   List<String> list = value.split(',');
   for (int i = 0; i < 7; i++) {
    list[i] = list[i].trim();
   }
   List<DateTime> list2 = list.map<DateTime>((DateTime.parse)).toList();
   return list2;
  }
  
  double _getAvg(DateTime sunday) {
    double totalSlept=0.0;
    double daysRecorded=0.0;

    for(int i = 0; i < weekHours.length; i++){
      if(weekHours[i] == 0) continue;
      totalSlept += weekHours[i];
      daysRecorded++;
    }
    if(totalSlept == 0) return 0.0;

    double avg = totalSlept/daysRecorded;
    sleepDebtTemp += ((daysRecorded * 8 * 60) - (totalSlept));
    if(today.isAfter(sunday.add(const Duration(days: 7)))){
      sleepDebt = sleepDebtTemp;
      SecureStorage().writeSecureData("SleepDebt", "$sleepDebt");
    }
    return avg;
  }

    void setSleepDebt() async {
    String value = await SecureStorage().readSecureData("SleepDebt");
    if(value != '') {
      sleepDebt = double.parse(value);
      sleepDebtTemp = sleepDebt;
    }
  }

}