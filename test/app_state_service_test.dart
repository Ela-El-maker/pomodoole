import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/services/app_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppStateService.initialize', () {
    test('falls back to medium when stored haptic index is invalid', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'haptic_intensity': 999,
      });

      final service = AppStateService();
      await service.initialize();

      expect(service.hapticIntensity, HapticIntensity.medium);
    });

    test('uses stored haptic index when value is valid', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'haptic_intensity': HapticIntensity.strong.index,
      });

      final service = AppStateService();
      await service.initialize();

      expect(service.hapticIntensity, HapticIntensity.strong);
    });
  });
}
