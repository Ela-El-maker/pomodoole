import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/app/app.dart';
import 'package:pomodorofocus/app/bootstrap/app_bootstrap.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/catalog_repository.dart';
import 'package:pomodorofocus/services/app_state_service.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:pomodorofocus/widgets/custom_error_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  await AppBootstrap.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppBootstrap.installGlobalErrorHandlers();
    await AppBootstrap.initializeObservability();

    await AppStateService().initialize();
    final startupLogger = const AppLogger();
    final startupDb = AppDatabase();
    try {
      await CatalogRepository(startupDb).seedDefaultsIfMissing();
      startupLogger.info(
        'bootstrap',
        'Catalog and achievement defaults ensured',
      );
    } catch (error, stackTrace) {
      startupLogger.warn(
        'bootstrap',
        'Failed to seed local reference data',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      await startupDb.close();
    }
    final sharedPreferences = await SharedPreferences.getInstance();

    var hasShownError = false;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (!hasShownError) {
        hasShownError = true;
        Future.delayed(const Duration(seconds: 5), () {
          hasShownError = false;
        });
        return CustomErrorWidget(errorDetails: details);
      }
      return const SizedBox.shrink();
    };

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appLoggerProvider.overrideWithValue(const AppLogger()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return const PomodoroFocusApp();
      },
    );
  }
}
