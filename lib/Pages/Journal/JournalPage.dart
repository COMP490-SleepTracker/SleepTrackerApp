import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sleeptrackerapp/Model/AuthenticationManager.dart';
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
  TextEditingController textcontroller = TextEditingController();
  Map<DateTime, String> entries = HashMap();
  double textBoxHeight = 350;

  @override
  void initState() {
    super.initState();
    _resetSelectedDate();
  }

  void _resetSelectedDate() {
    DateTime today = DateTime.now();
    today = today.subtract(Duration(hours: today.hour, minutes: today.minute, seconds: today.second, milliseconds: today.millisecond, microseconds: today.microsecond));
    _selectedDate = today;
    setJournalEntry(_selectedDate);
  }

  void setJournalEntry(DateTime date) {
    if (entries.containsKey(date)) {
      textcontroller.text = entries[date].toString();
    } else {
      textcontroller.text = '';
    }
  }

  void submitAndExpandText(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (textcontroller.text.isNotEmpty &&
        entries[_selectedDate] != textcontroller.text) {
      entries.addAll({_selectedDate: textcontroller.text});
    }
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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(5),
              ),
              CalendarTimeline(
                showYears: true,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 4)),
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
          ),
        ));
  }
}
