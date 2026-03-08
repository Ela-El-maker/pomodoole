import 'package:flutter/material.dart';
import '../presentation/statistics_screen/statistics_screen.dart';
import '../presentation/timer_screen/timer_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/task_management_screen/task_management_screen.dart';
import '../presentation/onboarding_welcome_screen/onboarding_welcome_screen.dart';
import '../presentation/onboarding_setup_flow_screen/onboarding_setup_flow_screen.dart';
import '../presentation/focus_screen/focus_screen.dart';
import '../presentation/active_focus_mode_screen/active_focus_mode_screen.dart';
import '../presentation/session_completion_screen/session_completion_screen.dart';
import '../presentation/break_screen/break_screen.dart';
import '../presentation/tasks_screen/tasks_screen.dart';
import '../presentation/custom_sound_mixer_screen/custom_sound_mixer_screen.dart';
import '../presentation/post_session_reflection_screen/post_session_reflection_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String statistics = '/statistics-screen';
  static const String timer = '/timer-screen';
  static const String settings = '/settings-screen';
  static const String taskManagement = '/task-management-screen';
  static const String onboardingWelcome = '/onboarding-welcome-screen';
  static const String onboardingSetupFlow = '/onboarding-setup-flow-screen';
  static const String focusScreen = '/focus-screen';
  static const String activeFocusMode = '/active-focus-mode-screen';
  static const String sessionCompletion = '/session-completion-screen';
  static const String breakScreen = '/break-screen';
  static const String tasksScreen = '/tasks-screen';
  static const String customSoundMixer = '/custom-sound-mixer-screen';
  static const String postSessionReflection = '/post-session-reflection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingWelcomeScreen(),
    statistics: (context) => const StatisticsScreen(),
    timer: (context) => const TimerScreen(),
    settings: (context) => const SettingsScreen(),
    taskManagement: (context) => const TaskManagementScreen(),
    onboardingWelcome: (context) => const OnboardingWelcomeScreen(),
    onboardingSetupFlow: (context) => const OnboardingSetupFlowScreen(),
    focusScreen: (context) => const FocusScreen(),
    activeFocusMode: (context) => const ActiveFocusModeScreen(),
    sessionCompletion: (context) => const SessionCompletionScreen(),
    breakScreen: (context) => const BreakScreen(),
    tasksScreen: (context) => const TasksScreen(),
    customSoundMixer: (context) => const CustomSoundMixerScreen(),
    postSessionReflection: (context) => const PostSessionReflectionScreen(),
  };
}
