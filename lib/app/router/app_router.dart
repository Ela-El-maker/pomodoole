import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodorofocus/app/router/app_shell.dart';
import 'package:pomodorofocus/app/router/route_paths.dart';
import 'package:pomodorofocus/features/debug/debug_diagnostics_screen.dart';
import 'package:pomodorofocus/presentation/break_screen/break_screen.dart';
import 'package:pomodorofocus/presentation/custom_sound_mixer_screen/custom_sound_mixer_screen.dart';
import 'package:pomodorofocus/presentation/onboarding_setup_flow_screen/onboarding_setup_flow_screen.dart';
import 'package:pomodorofocus/presentation/onboarding_welcome_screen/onboarding_welcome_screen.dart';
import 'package:pomodorofocus/presentation/post_session_reflection_screen/post_session_reflection_screen.dart';
import 'package:pomodorofocus/presentation/session_completion_screen/session_completion_screen.dart';
import 'package:pomodorofocus/presentation/settings_screen/settings_screen.dart';
import 'package:pomodorofocus/presentation/statistics_screen/statistics_screen.dart';
import 'package:pomodorofocus/presentation/tasks_screen/tasks_screen.dart';
import 'package:pomodorofocus/presentation/timer_screen/timer_screen_initial_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.onboardingWelcome,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final legacyTarget = RoutePaths.legacyRedirects[state.matchedLocation];
      if (legacyTarget != null) {
        return legacyTarget;
      }
      if (state.matchedLocation == RoutePaths.root) {
        return RoutePaths.onboardingWelcome;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.onboardingWelcome,
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingSetupFlow,
        builder: (context, state) => const OnboardingSetupFlowScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.timer,
                builder: (context, state) => const TimerScreenInitialPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.tasks,
                builder: (context, state) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.statistics,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.customSoundMixer,
        builder: (context, state) => const CustomSoundMixerScreen(),
      ),
      GoRoute(
        path: RoutePaths.breakScreen,
        builder: (context, state) {
          final args = state.extra;
          if (args is Map<String, dynamic>) {
            return BreakScreen(
              isLongBreak: args['isLongBreak'] as bool?,
              completedSessions: args['completedSessions'] as int?,
              totalSessions: args['totalSessions'] as int?,
            );
          }
          return const BreakScreen();
        },
      ),
      GoRoute(
        path: RoutePaths.sessionCompletion,
        builder: (context, state) {
          final args = state.extra;
          if (args is Map<String, dynamic>) {
            return SessionCompletionScreen(
              completedSessions: args['completedSessions'] as int?,
              totalSessions: args['totalSessions'] as int?,
            );
          }
          return const SessionCompletionScreen();
        },
      ),
      GoRoute(
        path: RoutePaths.postSessionReflection,
        builder: (context, state) => const PostSessionReflectionScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: RoutePaths.debugDiagnostics,
          builder: (context, state) => const DebugDiagnosticsScreen(),
        ),
    ],
  );
}
