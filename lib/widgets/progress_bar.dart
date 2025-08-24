import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      width: 250,
      lineHeight: 14.0,
      percent: progress,
      center: Text("${(progress * 100).toStringAsFixed(0)}%"),
      linearStrokeCap: LinearStrokeCap.roundAll,
      progressColor: Colors.blue,
    );
  }
}
