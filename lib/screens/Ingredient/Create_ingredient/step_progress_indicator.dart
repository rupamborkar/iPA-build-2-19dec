import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index % 2 == 0) {
          // Even index: Circle
          int step = index ~/ 2;
          return buildCircle(step);
        } else {
          // Odd index: Line
          int step = (index + 1) ~/ 2;
          return buildLine(step);
        }
      }),
    );
  }

  // Circle widget without numbers
  Widget buildCircle(int step) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Color.fromRGBO(0, 128, 128, 1) : Colors.white,
        border: Border.all(
          color: isCompleted ? Color.fromRGBO(0, 128, 128, 1) : Colors.grey,
          width: 2,
        ),
      ),
    );
  }

  // Line widget between circles with dynamic color based on the step
  Widget buildLine(int step) {
    return Expanded(
      child: Container(
        height: 2,
        color: currentStep >= step
            ? Color.fromRGBO(0, 128, 128, 1)
            : Colors.grey[300],
      ),
    );
  }
}
