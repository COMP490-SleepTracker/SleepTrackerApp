import 'package:flutter/material.dart';
import 'package:sleeptrackerapp/Model/DataManager/SecureStorage.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key, required String title});

  @override
  State<AlarmPage> createState() => AlarmPageState();
}

String selectedOption = "";
double _currentSliderValue = 50;
bool vibrationSetting = true;
late bool fetched;

Future<String> readAlarm() async {
  String filename = await SecureStorage().readSecureData("Alarm-Choice");
  return filename == "" ? "alarm.mp3" : filename;
}

Future<double> readVolume() async {
  String volume = await SecureStorage().readSecureData("Alarm-Volume");
  return volume == "" ? 50 : double.parse(volume);
}

Future<bool> readVibration() async {
  String vibration = await SecureStorage().readSecureData("Alarm-Vibration");
  return vibration == "" ? true : bool.parse(vibration);
}

class AlarmPageState extends State<AlarmPage> {
  @override
  void initState() {
    super.initState();
    fetched = false;
  }

  @override
  void dispose(){
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Alarm Settings"),
        ),
        body: Column(
          children: [
            FutureBuilder(
                future: readAlarm(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (selectedOption == "") {
                      selectedOption = snapshot.data as String;
                    }
                  }
                  return Column(
                    children: [
                      const Divider(),
                      const Text("Alarm Tone", style: TextStyle(fontSize: 20)),
                      ListTile(
                        title: const Text('Default'),
                        leading: Radio<String>(
                          value: "alarm.mp3",
                          groupValue: selectedOption,
                          onChanged: setAlarmChoice,
                        ),
                      ),
                      ListTile(
                        title: const Text('Alarm Clock'),
                        leading: Radio<String>(
                          value: "AlarmClock.mp3",
                          groupValue: selectedOption,
                          onChanged: setAlarmChoice,
                        ),
                      ),
                      ListTile(
                        title: const Text('Ringtone'),
                        leading: Radio<String>(
                          value: "Ringtone.mp3",
                          groupValue: selectedOption,
                          onChanged: setAlarmChoice,
                        ),
                      ),
                      const Divider(),
                      FutureBuilder(
                          future: readVolume(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (_currentSliderValue == 50) {
                                _currentSliderValue = snapshot.data as double;
                              }
                            }
                            return Column(
                              children: [
                                Text(
                                    "Alarm Volume: ${_currentSliderValue.toStringAsFixed(0)}",
                                    style: const TextStyle(fontSize: 20)),
                                SizedBox(
                                  width: 350,
                                  child: Slider(
                                    max: 100,
                                    min: 0,
                                    value: _currentSliderValue,
                                    onChanged: (double value) => setState(() {
                                      _currentSliderValue = value;
                                    }),
                                    onChangeEnd: (double value) =>
                                        SecureStorage().writeSecureData(
                                            "Alarm-Volume", value.toString()),
                                  ),
                                )
                              ],
                            );
                          }),
                          const Divider(),
                          const Text("Vibration", style: TextStyle(fontSize: 20),),
                          FutureBuilder(
                            future: readVibration(),
                            builder: (context,snapshot) {
                              if(snapshot.hasData && fetched == false){
                                vibrationSetting = snapshot.data as bool;
                                fetched = true;
                              }
                              return Switch(value: vibrationSetting, onChanged: (value) => {setState(() {
                                vibrationSetting = value;
                                setVibration(value);
                              })});
                            }
                          )
                    ],
                  );
                }),
          ],
        ));
  }

  void setAlarmChoice(value) {
    setState(() {
      selectedOption = value;
      SecureStorage().writeSecureData("Alarm-Choice", value);
    });
  }

  void setVibration(bool value) {
    SecureStorage().writeSecureData("Alarm-Vibration", value.toString());
  }
}