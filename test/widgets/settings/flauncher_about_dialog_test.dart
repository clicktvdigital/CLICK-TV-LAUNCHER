import 'package:flauncher/widgets/settings/flauncher_about_dialog.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

const _methodChannel = MethodChannel('me.efesser.flauncher/method');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSettingsService settingsService;

  setUp(() {
    settingsService = MockSettingsService();
    when(settingsService.accentColorHex).thenReturn('7C4DFF');
    PackageInfoPlatform.instance = _FakePackageInfoPlatform();
  });

  tearDown(() {
    _methodChannel.setMockMethodCallHandler(null);
  });

  testWidgets('shows the four official links and opens their exact URLs', (tester) async {
    final openedUrls = <String>[];
    _methodChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'openUrl') {
        openedUrls.add(call.arguments as String);
        return true;
      }
      fail('Unhandled method: ${call.method}');
    });

    await _pumpAboutDialog(tester, settingsService);

    expect(find.text('ENLACES OFICIALES'), findsOneWidget);
    expect(find.text('Tienda online'), findsOneWidget);
    expect(find.text('TV en vivo'), findsOneWidget);
    expect(find.text('Streaming'), findsOneWidget);
    expect(find.text('Contacto directo · Telegram'), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);

    await tester.tap(find.text('Tienda online'));
    await tester.tap(find.text('TV en vivo'));
    await tester.tap(find.text('Streaming'));
    await tester.tap(find.text('Contacto directo · Telegram'));
    await tester.pumpAndSettle();

    expect(openedUrls, [
      'https://click-tv-streaming.vercel.app',
      'https://t.me/clicktvgo',
      'https://t.me/click_tv_streaming',
      'https://t.me/clicktvdigital',
    ]);
  });

  testWidgets('moves focus with the remote and activates the focused link', (tester) async {
    String? openedUrl;
    _methodChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'openUrl') {
        openedUrl = call.arguments as String;
        return true;
      }
      fail('Unhandled method: ${call.method}');
    });

    await _pumpAboutDialog(tester, settingsService);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(openedUrl, 'https://t.me/clicktvgo');
  });

  testWidgets('keeps the dialog open and reports an unavailable URL handler', (tester) async {
    _methodChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'openUrl') return false;
      fail('Unhandled method: ${call.method}');
    });

    await _pumpAboutDialog(tester, settingsService);
    await tester.tap(find.text('Tienda online'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo abrir el enlace'), findsOneWidget);
    expect(find.text('ENLACES OFICIALES'), findsOneWidget);
    expect(find.text('Contacto directo · Telegram'), findsOneWidget);
  });

  testWidgets('closes only the about dialog with the close action', (tester) async {
    await _pumpAboutDialog(tester, settingsService);

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.byType(LTvLauncherAboutDialog), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

Future<void> _pumpAboutDialog(WidgetTester tester, SettingsService settingsService) async {
  final packageInfo = await PackageInfo.fromPlatform();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => ChangeNotifierProvider<SettingsService>.value(
                value: settingsService,
                child: LTvLauncherAboutDialog(packageInfo: packageInfo),
              ),
            ),
            child: const Text('Abrir Acerca'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir Acerca'));
  await tester.pumpAndSettle();
}

class _FakePackageInfoPlatform with MockPlatformInterfaceMixin implements PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll({String? baseUrl}) async => PackageInfoData(
        appName: 'CLICK TV LAUNCHER',
        packageName: 'com.clicktv.launcher',
        version: '2026.10.31',
        buildNumber: '8113',
        buildSignature: '',
      );
}
