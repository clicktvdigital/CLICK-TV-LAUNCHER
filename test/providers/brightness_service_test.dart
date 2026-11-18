import 'package:flauncher/providers/brightness_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('me.efesser.flauncher/method');

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  });

  group('BrightnessService requestPermission', () {
    test('handles successful permission request', () async {
      bool methodCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestWriteSettingsPermission') {
            methodCalled = true;
            return null;
          }
          if (methodCall.method == 'checkWriteSettingsPermission') {
            return true;
          }
          return null;
        },
      );

      final sharedPreferences = await SharedPreferences.getInstance();
      final service = BrightnessService(sharedPreferences);

      await service.requestPermission();
      expect(methodCalled, isTrue);
    });

    test('catches and handles PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestWriteSettingsPermission') {
            throw PlatformException(code: 'ERROR', message: 'Test error');
          }
          if (methodCall.method == 'checkWriteSettingsPermission') {
            return true;
          }
          return null;
        },
      );

      final sharedPreferences = await SharedPreferences.getInstance();
      final service = BrightnessService(sharedPreferences);

      // Should not throw
      await service.requestPermission();
    });
  });

  group('BrightnessService scheduler', () {
    testWidgets('only rewrites system brightness when the value changes', (tester) async {
      // Todas las franjas con el mismo valor: el test no depende de la hora.
      SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.withData({
        'flutter.brightness_scheduler_enabled': true,
        'flutter.brightness_morning': 60,
        'flutter.brightness_day': 60,
        'flutter.brightness_afternoon': 60,
        'flutter.brightness_evening': 60,
        'flutter.brightness_night': 60,
      });
      var writes = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'setSystemBrightness') {
            writes++;
            return true;
          }
          if (methodCall.method == 'checkWriteSettingsPermission') {
            return true;
          }
          return null;
        },
      );

      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      final service = BrightnessService(sharedPreferences);

      await tester.pump(const Duration(minutes: 1));
      expect(writes, 1);

      // Con el launcher en segundo plano los ticks siguientes no escriben.
      await tester.pump(const Duration(minutes: 5));
      expect(writes, 1);

      // Cambiar la franja actual sí aplica el nuevo valor.
      await service.setBrightnessForSlot(service.getCurrentTimeSlot(), 30);
      expect(writes, 2);
      await tester.pump(const Duration(minutes: 2));
      expect(writes, 2);

      service.dispose();
    });
  });
}
