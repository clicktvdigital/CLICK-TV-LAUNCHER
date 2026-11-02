import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/accessibility_page.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

const _methodChannel = MethodChannel('me.efesser.flauncher/method');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _methodChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'checkAccessibilityPermission':
          return false;
        case 'openDefaultLauncherSettings':
          return true;
        case 'requestAccessibilityPermission':
          return false;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    _methodChannel.setMockMethodCallHandler(null);
  });

  for (final size in const [Size(1280, 720), Size(1920, 1080)]) {
    testWidgets('fits and remains readable at ${size.width}x${size.height}', (tester) async {
      _setViewport(tester, size);
      await _pumpPage(tester, isDefault: true);

      expect(tester.takeException(), isNull);
      expect(find.text('Accesibilidad'), findsOneWidget);
      expect(find.text('CLICK TV LAUNCHER es el lanzador predeterminado'), findsOneWidget);
      expect(find.text('Corrección del botón Inicio (Google TV)'), findsOneWidget);
      final homeFixTile = find.ancestor(
        of: find.text('Corrección del botón Inicio (Google TV)'),
        matching: find.byType(FocusableSettingsTile),
      );
      expect(
        find.descendant(
          of: homeFixTile,
          matching: find.text('Deshabilitado'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Si usas Google TV'), findsOneWidget);
    });
  }

  testWidgets('scrolls the complete page at narrow width with larger text', (tester) async {
    _setViewport(tester, const Size(360, 640));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _pumpPage(tester, isDefault: false);

    expect(tester.takeException(), isNull);
    final list = find.byType(ListView);
    expect(list, findsOneWidget);

    await tester.drag(list, const Offset(0, -420));
    await tester.pump();
    final hint = find.textContaining('Si usas Google TV');
    final scrollable = find.descendant(
      of: list,
      matching: find.byType(Scrollable),
    );
    expect(scrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      hint,
      240,
      scrollable: scrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(hint),
      alignment: 1.0,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(hint, findsOneWidget);
    expect(tester.getRect(hint).bottom, lessThanOrEqualTo(640));
    expect(find.text('CLICK TV LAUNCHER no es el lanzador predeterminado'), findsOneWidget);
  });

  testWidgets('remote arrows and Enter activate the focused default settings action', (tester) async {
    _setViewport(tester, const Size(1280, 720));
    await _pumpPage(tester, isDefault: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Back pops only the Accessibility route', (tester) async {
    _setViewport(tester, const Size(1280, 720));
    await _pumpPage(tester, isDefault: true, initialRoute: '/accessibility');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(AccessibilityPage), findsNothing);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required bool isDefault,
  String? initialRoute,
}) async {
  final appsService = MockAppsService();
  final launcherState = LauncherState();
  final settingsService = MockSettingsService();

  when(appsService.isDefaultLauncher()).thenAnswer((_) async => isDefault);
  when(settingsService.appHighlightAnimationEnabled).thenReturn(true);
  when(settingsService.startOnBoot).thenReturn(false);
  when(settingsService.accentColorHex).thenReturn('7C4DFF');

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppsService>.value(value: appsService),
        ChangeNotifierProvider<LauncherState>.value(value: launcherState),
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: initialRoute,
        routes: {
          if (initialRoute != null)
            '/': (_) => const Scaffold(body: Center(child: Text('Ajustes'))),
          '/accessibility': (_) => const Scaffold(body: AccessibilityPage()),
        },
        home: initialRoute == null ? const Scaffold(body: AccessibilityPage()) : null,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
