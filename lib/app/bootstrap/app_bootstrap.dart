import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/firebase_options.dart';

class AppBootstrap {
  AppBootstrap._();

  static const AppLogger _logger = AppLogger();

  static Future<void> initializeObservability() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      _logger.info('observability', 'Firebase initialized');
    } catch (error, stackTrace) {
      _logger.warn(
        'observability',
        'Firebase init skipped (likely missing platform config).',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void installGlobalErrorHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logger.error(
        'flutter_error',
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
      );

      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _logger.error(
        'platform_dispatcher',
        'Unhandled platform error',
        error: error,
        stackTrace: stackTrace,
      );
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
      return true;
    };
  }

  static Future<void> runGuarded(Future<void> Function() body) async {
    await runZonedGuarded(body, (error, stackTrace) {
      _logger.error(
        'run_zoned_guarded',
        'Unhandled zoned error',
        error: error,
        stackTrace: stackTrace,
      );
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
        ),
      );
    });
  }
}
