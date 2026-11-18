import 'package:flauncher/providers/network_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/network_traffic_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockNetworkService networkService;
  late MockSettingsService settingsService;
  late DateTime fakeNow;

  setUp(() {
    networkService = MockNetworkService();
    settingsService = MockSettingsService();
    fakeNow = DateTime(2026, 11, 18, 12);
    LiveTrafficRates.clock = () => fakeNow;
    when(networkService.networkType).thenReturn(NetworkType.Wired);
    when(networkService.hasUsageStatsPermission).thenReturn(true);
    when(networkService.dailyDataUsage).thenReturn(0);
    when(networkService.getDataUsageForPeriod(any)).thenAnswer((_) async => 5 * 1024 * 1024);
    when(settingsService.dataUsagePeriod).thenReturn('daily');
  });

  tearDown(() => LiveTrafficRates.clock = DateTime.now);

  Widget host({double width = 400}) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: kToolbarHeight,
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<NetworkService>.value(value: networkService),
                  ChangeNotifierProvider<SettingsService>.value(value: settingsService),
                ],
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: NetworkTrafficIndicator(),
                ),
              ),
            ),
          ),
        ),
      );

  test('formatRate is compact', () {
    expect(formatRate(null), '— KB/s');
    expect(formatRate(0), '0 KB/s');
    expect(formatRate(51200), '50 KB/s');
    expect(formatRate(3 * 1024 * 1024 + 300 * 1024), '3.3 MB/s');
  });

  testWidgets('shows live download and upload speed from traffic counters', (tester) async {
    final samples = [
      [1000000, 500000],
      [1000000 + 204800, 500000 + 20480], // +200 KB / +20 KB en 2 s
    ];
    var call = 0;
    when(networkService.getTrafficTotals()).thenAnswer((_) async => samples[call++ < 1 ? 0 : 1]);

    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.text('↓ — KB/s'), findsOneWidget);

    fakeNow = fakeNow.add(LiveTrafficRates.interval);
    await tester.pump(LiveTrafficRates.interval);
    await tester.pump();

    expect(find.text('↓ 100 KB/s'), findsOneWidget);
    expect(find.text('↑ 10 KB/s'), findsOneWidget);
    expect(find.byIcon(Icons.settings_ethernet), findsOneWidget);
  });

  testWidgets('shows the Wi-Fi icon when connected by Wi-Fi', (tester) async {
    when(networkService.networkType).thenReturn(NetworkType.Wifi);
    when(networkService.getTrafficTotals()).thenAnswer((_) async => [0, 0]);

    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });

  testWidgets('stops polling when the app goes to background', (tester) async {
    var calls = 0;
    when(networkService.getTrafficTotals()).thenAnswer((_) async {
      calls++;
      return [0, 0];
    });

    await tester.pumpWidget(host());
    await tester.pump();
    final before = calls;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(LiveTrafficRates.interval * 3);
    expect(calls, before);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(calls, greaterThan(before));
  });

  testWidgets('fits a narrow 56 dp slot without overflowing (scales down)', (tester) async {
    when(networkService.getTrafficTotals()).thenAnswer((_) async => [0, 0]);

    await tester.pumpWidget(host(width: 90));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(NetworkTrafficIndicator));
    expect(size.width, lessThanOrEqualTo(90));
    expect(size.height, lessThanOrEqualTo(kToolbarHeight));
  });

  testWidgets('hides the speed when the device has no traffic counters', (tester) async {
    when(networkService.getTrafficTotals()).thenAnswer((_) async => null);

    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.textContaining('KB/s'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
