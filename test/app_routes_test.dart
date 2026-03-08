import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/app/router/route_paths.dart';
import 'package:pomodorofocus/routes/app_routes.dart';

void main() {
  test('app route constants match canonical router paths', () {
    expect(AppRoutes.timer, RoutePaths.timer);
    expect(AppRoutes.tasksScreen, RoutePaths.tasks);
    expect(AppRoutes.statistics, RoutePaths.statistics);
    expect(AppRoutes.settings, RoutePaths.settings);
    expect(AppRoutes.onboardingWelcome, RoutePaths.onboardingWelcome);
  });

  test('legacy redirects are defined for migrated paths', () {
    expect(RoutePaths.legacyRedirects['/focus-screen'], RoutePaths.timer);
    expect(
      RoutePaths.legacyRedirects['/task-management-screen'],
      RoutePaths.tasks,
    );
    expect(
      RoutePaths.legacyRedirects['/active-focus-mode-screen'],
      RoutePaths.timer,
    );
  });
}
