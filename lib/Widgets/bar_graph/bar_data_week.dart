import 'package:sleeptrackerapp/Widgets/bar_graph/individual_bar.dart';

class BarDataWeek{
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thuAmount;
  final double friAmount;
  final double satAmount;

  BarDataWeek({
    required this.sunAmount,
    required this.monAmount,
    required this.tueAmount,
    required this.wedAmount,
    required this.thuAmount,
    required this.friAmount,
    required this.satAmount
  });

  List<IndividualBar> barData = [];

  void initializeBarData(){
    barData = [
      IndividualBar(x: 0, y: sunAmount/60),
      IndividualBar(x: 1, y: monAmount/60),
      IndividualBar(x: 2, y: tueAmount/60),
      IndividualBar(x: 3, y: wedAmount/60),
      IndividualBar(x: 4, y: thuAmount/60),
      IndividualBar(x: 5, y: friAmount/60),
      IndividualBar(x: 6, y: satAmount/60)
    ];
  }
}