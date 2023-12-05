import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef OnTimeChange = void Function(DateTime);

class ScrollableTimePicker extends StatefulWidget {
  const ScrollableTimePicker({super.key, 
  this.scale = 1,
  required this.onTimeChange, 
  this.showBorder = true, 
  this.borderColor = Colors.white,
  this.borderWidth = 2.5,
  this.timeColor = Colors.white});

  final double scale;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final Color timeColor;
  final OnTimeChange onTimeChange;

  @override
  State<ScrollableTimePicker> createState() => ScrollableTimePickerState();
}

class ScrollableTimePickerState extends State<ScrollableTimePicker> {
  DateTime today = DateTime.now();
  static int hour = 8;
  static int minute = 0;
  static int amPm = 0;
  NumberFormat minutesFormat = NumberFormat("00");
  

  DateTime formatTime(){
    int fullHour = hour + amPm == 24 ? 12 : hour + amPm == 12 ? 0 : hour + amPm;
    DateTime alarm = DateTime(today.year, today.month, today.day, fullHour, minute);
    if(alarm.isBefore(today)){
      alarm = alarm.add(const Duration(days: 1));
    }
    return alarm;
  }

  String formatHour(int index){
    return index>9 ? '$index' : '  $index';
  }

  @override
  Widget build(BuildContext context) {
    widget.onTimeChange(formatTime());
    TextStyle fontStyle = TextStyle(fontSize: 40 * widget.scale, color: widget.timeColor);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.bottomCenter,
            end: AlignmentDirectional.topCenter,
            stops: const [0, 0.5, 1],
            colors: [Colors.black.withOpacity(.8), Colors.black.withOpacity(0), Colors.black.withOpacity(.8)]),
          border:borderStyle(),
          borderRadius: const BorderRadius.all(Radius.circular(25))
        ),
        width: 240 * widget.scale,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 70 * widget.scale, maxHeight: 140 * widget.scale),
              child: ListWheelScrollView.useDelegate(
                controller: FixedExtentScrollController(initialItem: 7),
                  onSelectedItemChanged: (value) {
                    hour = value + 1;
                    widget.onTimeChange(formatTime());
                  },
                  overAndUnderCenterOpacity: 0.3,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50 * widget.scale,
                  childDelegate: ListWheelChildLoopingListDelegate(
                      children: List<Widget>.generate(
                          12,
                          (index) => SizedBox(
                              width: 60 * widget.scale,
                              child: Text(
                                formatHour(index+1),
                                style: fontStyle,
                                textAlign: TextAlign.justify,
                              ))))),
            ),
             SizedBox(
                height: 55 * widget.scale,
                child: Text(':', style: fontStyle, textAlign: TextAlign.center)),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 70 * widget.scale, maxHeight: 140 * widget.scale),
              child: ListWheelScrollView.useDelegate(
                  onSelectedItemChanged: (value) {
                    minute = value * 5;
                    widget.onTimeChange(formatTime());
                  },
                  overAndUnderCenterOpacity: 0.3,
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50 * widget.scale,
                  childDelegate: ListWheelChildLoopingListDelegate(
                      children: List<Widget>.generate(
                          12,
                          (index) => Text(minutesFormat.format(index * 5),
                              style: fontStyle)))),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 70 * widget.scale, maxHeight: 140 * widget.scale),
              child: ListWheelScrollView(
                  overAndUnderCenterOpacity: 0.3,
                  onSelectedItemChanged: (value) {
                    amPm = (value * 12);
                    widget.onTimeChange(formatTime());
                  },
                  physics: const FixedExtentScrollPhysics(),
                  itemExtent: 50 * widget.scale,
                  children:  <Widget>[
                    Text('AM', style: fontStyle),
                    Text('PM', style: fontStyle)
                  ]),
            )],
        ),
      );
  }

  Border borderStyle() {
    if(widget.showBorder == false) return const Border();
    return Border.all(
          color: widget.borderColor,
          width: widget.borderWidth * widget.scale
        );
  }
}
