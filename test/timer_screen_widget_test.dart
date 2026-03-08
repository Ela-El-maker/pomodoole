import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/presentation/timer_screen/timer_screen_initial_page.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:drift/drift.dart' as drift;

Future<void> pumpTimerScreen(
  WidgetTester tester, {
  required Size surfaceSize,
  required double textScale,
}) async {
  SharedPreferences.setMockInitialValues({
    'notifications_enabled': false,
    'vibration_enabled': false,
  });
  final prefs = await SharedPreferences.getInstance();

  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(() => db.close());

  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionHistoryRepositoryProvider.overrideWithValue(
          SessionHistoryRepository(db),
        ),
      ],
      child: Sizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            home: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: const TimerScreenInitialPage(),
            ),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('timer screen renders on phone and tablet sizes', (tester) async {
    await pumpTimerScreen(
      tester,
      surfaceSize: const Size(360, 640),
      textScale: 1.0,
    );

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpTimerScreen(
      tester,
      surfaceSize: const Size(768, 1024),
      textScale: 1.3,
    );

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timer screen handles large accessibility text scale', (
    tester,
  ) async {
    await pumpTimerScreen(
      tester,
      surfaceSize: const Size(393, 852),
      textScale: 2.0,
    );

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
