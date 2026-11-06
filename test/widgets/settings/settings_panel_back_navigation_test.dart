import 'package:flauncher/actions.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  testWidgets('Android TV Back returns one Settings level at a time', (tester) async {
    final appsService = MockAppsService();
    final favorites = fakeCategory(name: 'Favorites');
    when(appsService.launcherSections).thenReturn([favorites]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppsService>.value(
        value: appsService,
        child: Builder(
          builder: (context) {
            const backIntents = PrioritizedIntents(orderedIntents: [
              DismissIntent(),
              BackIntent(),
            ]);

            return MaterialApp(
              locale: const Locale('en'),
              shortcuts: {
                ...WidgetsApp.defaultShortcuts,
                const SingleActivator(LogicalKeyboardKey.escape): backIntents,
                const SingleActivator(LogicalKeyboardKey.gameButtonB): backIntents,
              },
              actions: {
                ...WidgetsApp.defaultActions,
                BackIntent: BackAction(context),
              },
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                key: const Key('Home'),
                body: Center(
                  child: ElevatedButton(
                    key: const Key('OpenSettings'),
                    onPressed: () => Navigator.of(tester.element(find.byKey(const Key('Home')))).push(
                      MaterialPageRoute(builder: (_) => const SettingsPanel()),
                    ),
                    child: const Text('Open settings'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('OpenSettings')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Interface'));
    await tester.pumpAndSettle();
    expect(find.text('Interface'), findsOneWidget);
    expect(find.text('Sections'), findsOneWidget);

    await tester.tap(find.text('Sections'));
    await tester.pumpAndSettle();
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Favorite Apps'), findsOneWidget);

    await tester.tap(find.text('Favorite Apps'));
    await tester.pumpAndSettle();
    expect(find.text('Modify section'), findsOneWidget);

    // Android KEYCODE_BACK is delivered through the platform pop-route path.
    // A goBack key event must not add a second navigation operation for the
    // same physical gesture.
    await tester.sendKeyEvent(
      LogicalKeyboardKey.goBack,
      physicalKey: PhysicalKeyboardKey.escape,
      platform: 'android',
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Modify section'), findsNothing);
    expect(find.text('Favorite Apps'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Favorite Apps'), findsNothing);
    expect(find.text('Sections'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.gameButtonB);
    await tester.pumpAndSettle();
    expect(find.text('Sections'), findsNothing);
    expect(find.text('Interface'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Interface'), findsNothing);
    expect(find.byKey(const Key('Home')), findsOneWidget);

    expect(FocusManager.instance.primaryFocus, isNotNull);
  });
}
