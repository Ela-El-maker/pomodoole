class RoutePaths {
  RoutePaths._();

  static const String root = '/';
  static const String onboardingWelcome = '/onboarding-welcome-screen';
  static const String onboardingSetupFlow = '/onboarding-setup-flow-screen';

  static const String timer = '/timer-screen';
  static const String tasks = '/tasks-screen';
  static const String statistics = '/statistics-screen';
  static const String settings = '/settings-screen';

  static const String customSoundMixer = '/custom-sound-mixer-screen';
  static const String breakScreen = '/break-screen';
  static const String sessionCompletion = '/session-completion-screen';
  static const String postSessionReflection = '/post-session-reflection-screen';
  static const String debugDiagnostics = '/debug-diagnostics';

  // Legacy routes preserved during migration.
  static const Map<String, String> legacyRedirects = {
    '/focus-screen': timer,
    '/active-focus-mode-screen': timer,
  };

  static const List<String> bottomTabPaths = [
    timer,
    tasks,
    statistics,
    settings,
  ];
}
