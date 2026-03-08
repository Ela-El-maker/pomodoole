import 'package:flutter/material.dart';
import 'package:pomodorofocus/app/router/app_router.dart';
import 'package:pomodorofocus/services/app_state_service.dart';
import 'package:pomodorofocus/theme/app_theme.dart';

class PomodoroFocusApp extends StatelessWidget {
  const PomodoroFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final selectedTheme = appState.highContrastMode
            ? AppTheme.highContrastTheme
            : AppTheme.lightTheme;

        return MaterialApp.router(
          title: 'Pomodoro Focus',
          debugShowCheckedModeBanner: false,
          theme: selectedTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
