import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
import 'package:sleeptrackerapp/Model/SecureStorage.dart';
import 'package:sleeptrackerapp/Pages/Main/LoginPage.dart';
import 'package:sleeptrackerapp/Pages/NavigationPanel.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key, required this.title});
  final String title;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late DateTime _selectedDate;
  late final Future firstDate = getFirstDate();
  TextEditingController textcontroller = TextEditingController();
  double textBoxHeight = 350;
  

  @override
  void initState() {
    _resetSelectedDate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
///Reads first date from storage. If empty, sets first date as today's date and writes into storage
  Future<String> getFirstDate() async {
      String first = await SecureStorage().readSecureData('FirstDate');
      if(first != ''){
        return first;
      }
      else{
         DateTime today = DateTime.now();
         today = today.subtract(Duration(hours: today.hour, minutes: today.minute, seconds: today.second, milliseconds: today.millisecond, microseconds: today.microsecond));
         SecureStorage().writeSecureData('FirstDate', today.toString());
         return today.toString();
      }
  }

///Sets calendar to today's date
  void _resetSelectedDate() {
    DateTime today = DateTime.now();
    today = today.subtract(Duration(hours: today.hour, minutes: today.minute, seconds: today.second, milliseconds: today.millisecond, microseconds: today.microsecond));
    _selectedDate = today;
    setJournalEntry(_selectedDate);
  }
///Reads journal entry from storage using selected date as key
  void setJournalEntry(DateTime date) async {
    textcontroller.text = await SecureStorage().readSecureData('Journal-$date');
  }
///Closes keyboard, writes journal into storage, and expands text field
  void submitAndExpandText(BuildContext context) {
    FocusScope.of(context).unfocus();
    SecureStorage().writeSecureData('Journal-$_selectedDate', textcontroller.text);
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      Future.delayed(const Duration(milliseconds: 200), () {
        textBoxHeight = 350;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!GetIt.instance<AuthenticationManager>().isAuthenticated) {
      // navigate to the main page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginPage(title: 'Sleep Tracker+')));
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        drawer: const NavigationPanel(),
        body: FutureBuilder(
          builder: (context, snapshot){
            //If future is retrieved from storage, load page
            if(snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasData){
                final data = snapshot.data as String;
                final firstDate = DateTime.parse(data);
                return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(5),
            ),
            CalendarTimeline(
              showYears: true,
              initialDate: _selectedDate,
              firstDate: firstDate,
              lastDate: _selectedDate,
              onDateSelected: (date) => setState(() {
                setJournalEntry(date);
                _selectedDate = (date);
              }),
              leftMargin: 10,
              monthColor: Colors.white70,
              dayColor: Colors.white70,
              dayNameColor: const Color(0xFF333A47),
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Colors.purple[200],
              dotsColor: const Color(0xFF333A47),
              selectableDayPredicate: null,
              locale: 'en',
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(color: Color(0xFF333A47)),
                ),
                onPressed: () => setState(() => _resetSelectedDate()),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              constraints: BoxConstraints(
                maxHeight: textBoxHeight,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: TextField(
                    onSubmitted: (value) => submitAndExpandText(context),
                    textInputAction: TextInputAction.done,
                    onTapOutside: (event) => submitAndExpandText(context),
                    onTap: () => setState(() => textBoxHeight = 85),
                    controller: textcontroller,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText:
                            'Log notes on your quality of sleep or dreams'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }, future: firstDate,
        )
        
        );
  }
}
