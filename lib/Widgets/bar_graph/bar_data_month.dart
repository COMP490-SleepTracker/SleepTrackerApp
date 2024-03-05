import 'package:sleeptrackerapp/Widgets/bar_graph/individual_bar.dart';

class BarDataMonth{
  final double week1;
  final double week2;
  final double week3;
  final double week4;
  final double week5;

  BarDataMonth({
    required this.week1,
    required this.week2,
    required this.week3,
    required this.week4,
    required this.week5,
  });

  List<IndividualBar> barData = [];

  void initializeBarData(){
    barData = [
      IndividualBar(x: 0, y: week1),
      IndividualBar(x: 1, y: week2),
      IndividualBar(x: 2, y: week3),
      IndividualBar(x: 3, y: week4),
      IndividualBar(x: 4, y: week5),
    ];
  }
}