import 'package:flauncher/providers/weather_service.dart';
import 'package:flauncher/providers/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/tv_inputs_service.dart';
import 'package:flauncher/providers/notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import '../mocks.mocks.dart';

void main() {
  late MockSettingsService mockSettingsService;
  late MockTvInputsService mockTvInputsService;
  late MockNotificationsService mockNotificationsService;
  late MockWeatherService mockWeatherService;
  late MockNetworkService mockNetworkService;

  void setupSettingsDefaults(MockSettingsService service) {
    when(service.autoHideAppBarEnabled).thenReturn(false);
    when(service.showNetworkIndicatorInStatusBar).thenReturn(false);
    when(service.showDataWidgetInStatusBar).thenReturn(false);
    when(service.showDateInStatusBar).thenReturn(true);
    when(service.showTimeInStatusBar).thenReturn(true);
    when(service.showInputsWidgetInStatusBar).thenReturn(true);
    when(service.showNotificationsWidgetInStatusBar).thenReturn(true);
    when(service.autoHideNotificationsWidget).thenReturn(false);
    when(service.dateFormat).thenReturn(SettingsService.defaultDateFormat);
    when(service.timeFormat).thenReturn(SettingsService.defaultTimeFormat);
    when(service.showWeatherInStatusBar).thenReturn(false);
    when(service.showWeatherWarnings).thenReturn(false);
    when(service.useFahrenheit).thenReturn(false);
  }

  setUp(() {
    mockSettingsService = MockSettingsService();
    mockTvInputsService = MockTvInputsService();
    mockNotificationsService = MockNotificationsService();
    mockWeatherService = MockWeatherService();
    mockNetworkService = MockNetworkService();
    when(mockNetworkService.reconnecting).thenReturn(false);
    when(mockNetworkService.networkType).thenReturn(NetworkType.Wired);
    when(mockNetworkService.hasInternetAccess).thenReturn(true);

    setupSettingsDefaults(mockSettingsService);

    when(mockTvInputsService.hasInputs).thenReturn(false);
    when(mockNotificationsService.hasPermission).thenReturn(false);
    when(mockNotificationsService.notifications).thenReturn([]);
    when(mockWeatherService.hasWeather).thenReturn(false);
    when(mockWeatherService.weatherData).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        appBar: FocusAwareAppBar(),
        body: Container(),
      ),
    );
  }

  testWidgets('FocusAwareAppBar renders settings button and date/time widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );

    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byKey(const Key('statusbar_date')), findsOneWidget);
    expect(find.byKey(const Key('statusbar_clock')), findsOneWidget);
  });

  testWidgets('FocusAwareAppBar auto-hide logic', (WidgetTester tester) async {
    when(mockSettingsService.autoHideAppBarEnabled).thenReturn(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );

    // Initial state: app bar height should be 0 because auto-hide is true and focused is false
    final animatedContainer = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(animatedContainer.constraints?.maxHeight, 0);

    // Trigger focus to show app bar
    final focusWidget = tester.widget<Focus>(find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(Focus)).first);
    focusWidget.onFocusChange?.call(true);

    await tester.pumpAndSettle();

    // After focus: app bar height should be clickTvStatusBarHeight
    final animatedContainerFocused = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(animatedContainerFocused.constraints?.maxHeight, clickTvStatusBarHeight);
  });

  testWidgets('FocusAwareAppBar renders inputs button based on setting and availability', (WidgetTester tester) async {
    // Case 1: showInputsWidgetInStatusBar is true, and hasInputs is true
    when(mockSettingsService.showInputsWidgetInStatusBar).thenReturn(true);
    when(mockTvInputsService.hasInputs).thenReturn(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );

    expect(find.byIcon(Icons.tv_outlined), findsOneWidget);

    // Case 2: showInputsWidgetInStatusBar is false, and hasInputs is true
    await tester.pumpWidget(Container()); // fully unmount previous tree
    await tester.pumpAndSettle();

    final mockSettingsService2 = MockSettingsService();
    setupSettingsDefaults(mockSettingsService2);
    when(mockSettingsService2.showInputsWidgetInStatusBar).thenReturn(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService2),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.tv_outlined), findsNothing);
  });

  testWidgets('FocusAwareAppBar auto-hide notification bell logic', (WidgetTester tester) async {
    // Case 1: autoHideNotificationsWidget is true, notification count is 0
    when(mockSettingsService.autoHideNotificationsWidget).thenReturn(true);
    when(mockNotificationsService.hasPermission).thenReturn(true);
    when(mockNotificationsService.notifications).thenReturn([]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    expect(find.byIcon(Icons.notifications_active_outlined), findsNothing);

    // Case 2: autoHideNotificationsWidget is true, notification count is > 0
    await tester.pumpWidget(Container()); // fully unmount previous tree
    await tester.pumpAndSettle();

    final item = NotificationItem(
      key: '1',
      packageName: 'com.example',
      title: 'Title',
      text: 'Text',
      isClearable: true,
    );
    when(mockNotificationsService.notifications).thenReturn([item]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: createWidgetUnderTest(),
      )
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
  });

  testWidgets('reconnect button refreshes network and weather and reports the result', (tester) async {
    when(mockNetworkService.reconnect()).thenAnswer((_) async => true);
    when(mockWeatherService.refresh()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<TvInputsService>.value(value: mockTvInputsService),
          ChangeNotifierProvider<NotificationsService>.value(value: mockNotificationsService),
          ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ChangeNotifierProvider<NetworkService>.value(value: mockNetworkService),
        ],
        child: MaterialApp(
          home: Scaffold(appBar: FocusAwareAppBar(), body: const SizedBox()),
        ),
      ),
    );
    await tester.pump();

    final button = find.byKey(const Key('reconnect-network-button'));
    expect(button, findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);

    // Operable con el control remoto: foco + OK.
    final focusNode = Focus.of(tester.element(find.descendant(of: button, matching: find.byType(InkWell))));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();

    verify(mockNetworkService.reconnect()).called(1);
    verify(mockWeatherService.refresh()).called(1);
    await tester.pump();
    expect(find.textContaining('Connection checked'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
