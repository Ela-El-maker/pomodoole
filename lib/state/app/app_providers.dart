import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at app bootstrap.',
  );
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const AppLogger();
});
