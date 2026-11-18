import 'package:flauncher/models/weather_data.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/weather_service.dart';
import 'package:flauncher/widgets/weather_status_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockSettingsService mockSettingsService;
  late MockWeatherService mockWeatherService;

  final testWeatherWithWarning = WeatherData.fromJsonString('''
  {
    "timestamp": ${DateTime.now().millisecondsSinceEpoch ~/ 1000},
    "currentTemp": 27,
    "currentConditionCode": 800,
    "currentCondition": "Clear",
    "forecasts": [
      {
        "conditionCode": 500,
        "precipProbability": 80,
        "minTemp": 20,
        "maxTemp": 30
      }
    ]
  }
  ''');

  setUp(() {
    mockSettingsService = MockSettingsService();
    mockWeatherService = MockWeatherService();

    when(mockSettingsService.showWeatherInStatusBar).thenReturn(true);
    when(mockSettingsService.useFahrenheit).thenReturn(false);
    when(mockWeatherService.hasWeather).thenReturn(true);
    when(mockWeatherService.weatherData).thenReturn(testWeatherWithWarning);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
            ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
          ],
          child: const WeatherStatusBarWidget(),
        ),
      ),
    );
  }

  testWidgets('renders harmonized styling when weather warnings is disabled', (tester) async {
    when(mockSettingsService.showWeatherWarnings).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.textContaining('27°C'), findsOneWidget);

    final textWidget = tester.widget<Text>(find.textContaining('27°C'));
    expect(textWidget.style?.color, Colors.white);
    expect(textWidget.style?.fontWeight, FontWeight.w400);

    final iconWidget = tester.widget<Icon>(find.byType(Icon));
    expect(iconWidget.icon, Icons.wb_sunny_outlined);
    expect(iconWidget.color, Colors.white);

    final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final boxDecoration = container.decoration as BoxDecoration;
    final border = boxDecoration.border as Border;
    expect(border.top.color, Colors.white.withOpacity(0.12));
    expect(border.top.width, 1.0);
  });

  testWidgets('renders harmonized styling and current icon when weather warnings is enabled', (tester) async {
    when(mockSettingsService.showWeatherWarnings).thenReturn(true);

    await tester.pumpWidget(createWidgetUnderTest());

    // Warning text is included in displayText without altering colors/outline/icon
    expect(find.text('27°C • 80% Rain tomorrow'), findsOneWidget);

    final textWidget = tester.widget<Text>(find.text('27°C • 80% Rain tomorrow'));
    expect(textWidget.style?.color, Colors.white);
    expect(textWidget.style?.fontWeight, FontWeight.w400);

    // Current condition icon remains sunny, not overridden by warning
    final iconWidget = tester.widget<Icon>(find.byType(Icon));
    expect(iconWidget.icon, Icons.wb_sunny_outlined);
    expect(iconWidget.color, Colors.white);

    // Border remains subtle white with width 1.0, not amber
    final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final boxDecoration = container.decoration as BoxDecoration;
    final border = boxDecoration.border as Border;
    expect(border.top.color, Colors.white.withOpacity(0.12));
    expect(border.top.width, 1.0);
  });

  testWidgets('long weather details fit in the 56 dp top bar as 3 single lines', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final staleTimestamp =
        DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch ~/ 1000;
    final longWeather = WeatherData.fromJsonString('''
    {
      "timestamp": $staleTimestamp,
      "location": "Atucucho de San Antonio de Pichincha, Quito, Ecuador",
      "currentTemp": 9,
      "todayMaxTemp": 18,
      "todayMinTemp": 10,
      "currentConditionCode": 741,
      "currentCondition": "Niebla densa con llovizna intermitente y viento",
      "forecasts": [
        {"conditionCode": 500, "precipProbability": 100, "minTemp": 10, "maxTemp": 18}
      ]
    }
    ''');
    when(mockSettingsService.showWeatherWarnings).thenReturn(false);
    when(mockWeatherService.weatherData).thenReturn(longWeather);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            height: kToolbarHeight,
            child: Center(
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
                  ChangeNotifierProvider<WeatherService>.value(value: mockWeatherService),
                ],
                child: const WeatherStatusBarWidget(),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final lines = tester.widgetList<Text>(find.descendant(
      of: find.byType(WeatherStatusBarWidget),
      matching: find.byType(Text),
    ));
    expect(lines.length, lessThanOrEqualTo(3));
    for (final line in lines) {
      expect(line.maxLines, 1);
      expect(line.overflow, TextOverflow.ellipsis);
    }
    final box = tester.getSize(find.byType(AnimatedContainer));
    expect(box.height, lessThanOrEqualTo(kToolbarHeight));
  });
}
