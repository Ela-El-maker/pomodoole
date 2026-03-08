import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/main.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app renders onboarding welcome content', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appLoggerProvider.overrideWithValue(const AppLogger()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('A quiet place to work.'), findsOneWidget);
  });
}
