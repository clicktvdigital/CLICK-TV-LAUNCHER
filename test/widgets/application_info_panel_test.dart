/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  setUp(() => FocusKeyboardListener.lastValidationKeyEventAt = null);

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = Size(1280, 720);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    // Scale-down the font size because the font 'Ahem' used when running tests is much wider than Roboto
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("'Open' calls launchApp on AppsService", (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    when(appsService.applications).thenReturn([app]);
    await _pumpWidgetWithProviders(tester, appsService, null, app);

    final finder = find.text("Open");
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    verify(appsService.launchApp(app));
  });

  testWidgets("'Hide' calls AppsService", (tester) async {
    final appsService = MockAppsService();
    final category = fakeCategory(name: "Category 1", order: 0);
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    category.applications.add(app);
    when(appsService.launcherSections).thenReturn([category]);
    when(appsService.applications).thenReturn([]);
    await _pumpWidgetWithProviders(tester, appsService, category, app);

    final finder = find.text("Hide");
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    verify(appsService.hideApplication(app));
  });

  testWidgets("'Remove from...' calls AppsService", (tester) async {
    final appsService = MockAppsService();
    final category = fakeCategory(name: "Category 1", order: 0);
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    category.applications.add(app);
    when(appsService.launcherSections).thenReturn([category]);
    when(appsService.applications).thenReturn([]);
    await _pumpWidgetWithProviders(tester, appsService, category, app);

    final finder = find.text("Remove from Category 1");
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    verify(appsService.removeFromCategory(app, category));
  });

  testWidgets("'App info' calls AppsService", (tester) async {
    final appsService = MockAppsService();
    final category = fakeCategory(name: "Category 1", order: 0);
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    category.applications.add(app);
    when(appsService.launcherSections).thenReturn([category]);
    when(appsService.applications).thenReturn([]);
    await _pumpWidgetWithProviders(tester, appsService, category, app);

    final finder = find.text("Application info");
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    verify(appsService.openAppInfo(app));
  });

  testWidgets("'Uninstall' calls AppsService", (tester) async {
    final appsService = MockAppsService();
    final category = fakeCategory(name: "Category 1", order: 0);
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      version: "1.0.0",
    );
    category.applications.add(app);
    when(appsService.launcherSections).thenReturn([category]);
    when(appsService.applications).thenReturn([]);
    await _pumpWidgetWithProviders(tester, appsService, category, app);

    final finder = find.text("Uninstall");
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    verify(appsService.uninstallApp(app));
  });

  testWidgets('OK-long-press menu lists Open, App info and Uninstall first, with Open focused', (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(packageName: "me.efesser.flauncher", name: "FLauncher", version: "1.0.0");
    when(appsService.applications).thenReturn([app]);
    await _pumpWidgetWithProviders(tester, appsService, null, app);

    final open = find.byKey(const Key('app-panel-open'));
    final info = find.byKey(const Key('app-panel-info'));
    final uninstall = find.byKey(const Key('app-panel-uninstall'));
    expect(tester.getTopLeft(open).dy, lessThan(tester.getTopLeft(info).dy));
    expect(tester.getTopLeft(info).dy, lessThan(tester.getTopLeft(uninstall).dy));
    expect(tester.getTopLeft(uninstall).dy,
        lessThan(tester.getTopLeft(find.text("Add to...")).dy));

    final focused = FocusManager.instance.primaryFocus?.context;
    expect(focused, isNotNull);
    var focusIsOnOpen = false;
    focused!.visitAncestorElements((element) {
      if (element.widget.key == const Key('app-panel-open')) {
        focusIsOnOpen = true;
        return false;
      }
      return true;
    });
    expect(focusIsOnOpen, isTrue);

    // Flecha abajo + OK abre la información de la app.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    verify(appsService.openAppInfo(app)).called(1);
    verifyNever(appsService.launchApp(app));
  });

  testWidgets('OK still held from the long press does not trigger Open', (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(packageName: "me.efesser.flauncher", name: "FLauncher", version: "1.0.0");
    when(appsService.applications).thenReturn([app]);

    // El panel aparece mientras OK sigue presionado (pulsación larga de 1 s).
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await _pumpWidgetWithProviders(tester, appsService, null, app);

    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    // Par KeyUp/KeyDown sintetizado (control IR del TV box): sigue sostenido.
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    verifyNever(appsService.launchApp(app));

    // Una pulsación nueva sí abre la app.
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    verify(appsService.launchApp(app)).called(1);
  });
}

Future<void> _pumpWidgetWithProviders(
  WidgetTester tester,
  AppsService appsService,
  Category? category,
  App application,
) async {
  when(appsService.isAppInFavorites(application)).thenReturn(false);
  when(appsService.hasCustomBanner(application.packageName)).thenAnswer((_) async => false);
  when(appsService.getAppIcon(application.packageName)).thenAnswer((_) async => Uint8List(0));
  when(appsService.getAppBanner(application.packageName)).thenAnswer((_) async => Uint8List(0));

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppsService>.value(value: appsService),
      ],
      builder: (_, __) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ApplicationInfoPanel(
          category: category,
          application: application,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
