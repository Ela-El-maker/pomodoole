import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/presentation/onboarding_setup_flow_screen/widgets/weekly_goal_step_widget.dart';
import 'package:sizer/sizer.dart';

void main() {
  Future<void> pumpStep(
    WidgetTester tester, {
    required bool editable,
    required bool loading,
    String? lockMessage,
  }) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, screenType) => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WeeklyGoalStepWidget(
                selectedGoal: 30,
                isEditable: editable,
                isLoading: loading,
                lockMessage: lockMessage,
                onGoalSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('editable mode shows goal options and custom', (tester) async {
    await pumpStep(tester, editable: true, loading: false);

    expect(find.text('20 sessions'), findsOneWidget);
    expect(find.text('30 sessions'), findsOneWidget);
    expect(find.text('40 sessions'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('locked mode shows read-only goal card', (tester) async {
    await pumpStep(
      tester,
      editable: false,
      loading: false,
      lockMessage:
          'Goal can be edited after reaching it or when this week ends.',
    );

    expect(find.text('Current goal'), findsOneWidget);
    expect(find.text('30 sessions/week'), findsOneWidget);
    expect(find.textContaining('Goal can be edited'), findsOneWidget);
    expect(find.text('20 sessions'), findsNothing);
  });
}
