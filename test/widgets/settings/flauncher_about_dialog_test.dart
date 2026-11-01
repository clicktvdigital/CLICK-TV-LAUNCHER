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

  testWidgets('shows the three official links and opens their exact URLs', (tester) async {
    final openedUrls = <String>[];
    _methodChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'openUrl') {
        openedUrls.add(call.arguments as String);
        return true;
      }
      fail('Unhandled method: ${call.method}');
    });

    await _pumpAboutDialog(tester, settingsService);

    expect(find.text('Enlaces oficiales'), findsOneWidget);
    expect(find.text('Página oficial de CLICK TV'), findsOneWidget);
    expect(find.text('Telegram · Televisión en vivo'), findsOneWidget);
    expect(find.text('Telegram · Stream ID'), findsOneWidget);

    await tester.tap(find.text('Página oficial de CLICK TV'));
    await tester.tap(find.text('Telegram · Televisión en vivo'));
    await tester.tap(find.text('Telegram · Stream ID'));
    await tester.pumpAndSettle();

    expect(openedUrls, [
      'https://click-tv-streaming.vercel.app',
      'https://t.me/televisionenvivo',
      'https://t.me/streamid',
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

    expect(openedUrl, 'https://t.me/televisionenvivo');
  });

  testWidgets('keeps the dialog open and reports an unavailable URL handler', (tester) async {
    _methodChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'openUrl') return false;
      fail('Unhandled method: ${call.method}');
    });

    await _pumpAboutDialog(tester, settingsService);
    await tester.tap(find.text('Página oficial de CLICK TV'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo abrir el enlace'), findsOneWidget);
    expect(find.text('Enlaces oficiales'), findsOneWidget);
    expect(find.text('Telegram · Stream ID'), findsOneWidget);
  });
}

Future<void> _pumpAboutDialog(WidgetTester tester, SettingsService settingsService) async {
  final packageInfo = await PackageInfo.fromPlatform();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: LTvLauncherAboutDialog(packageInfo: packageInfo),
        ),
      ),
    ),
  );
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
