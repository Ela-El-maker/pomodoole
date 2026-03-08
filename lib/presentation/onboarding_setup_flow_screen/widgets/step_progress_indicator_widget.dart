import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StepProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: stepIndex < currentStep
                  ? const Color(0xFFA8C3A0)
                  : const Color(0xFFE0DED8),
            ),
          );
        } else {
          // Dot
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 3.w : 2.w,
            height: isCurrent ? 3.w : 2.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isCurrent
                  ? const Color(0xFFA8C3A0)
                  : const Color(0xFFE0DED8),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFFA8C3A0).withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }
      }),
    );
  }
}
